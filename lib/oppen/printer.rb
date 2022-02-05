module Oppen
  class Printer
    # TODO: make those kwargs proper params
    def initialize(**kwargs)
      # parametrization
      @margin      = kwargs[:margin]
      @offset      = kwargs[:offset]
      @output      = kwargs[:output]

      # initial state
      @right       = 0
      @left        = 0
      @left_total  = 0
      @right_total = 0
      @top         = 0
      @bottom      = 0
      @space       = @margin
      @print_stack = []
      n            = 3 * @margin
      @scan_stack_empy = true
      @scan_stack  = Array.new n
      @sizes       = Array.new n
      @tokens      = Array.new n
    end

    # Prints a single Token
    def pretty_print tkn
      case tkn[:type]
        in :break
          if !@scan_stack_empy then advance_right
          else
            @left_total  = 1
            @right_total = 1
            @left        = 0
            @right       = 0
          end
          check_stack 0
          scan_push @right
          @tokens[@right] = tkn
          @sizes[@right]  = -@right_total
          @right_total   += tkn[:len]
        in :end
          if @scan_stack_empy then print_stack_print tkn, 0
          else
            advance_right
            @tokens[@right] = tkn
            @sizes[@right]  = -1
            scan_push @right
          end
        in :eof
          if !@scan_stack_empy
            check_stack 0
            advance_left @tokens[@left], @sizes[@left]
          end
          indent 0
        in :begin
          if !@scan_stack_empy then advance_right
          else
            @left_total  = 1
            @right_total = 1
            @left        = 0
            @right       = 0
          end
          @tokens[@right] = tkn
          @sizes[@right]  = -@right_total
          scan_push @right
        in :string
          if @scan_stack_empy then print_stack_print tkn, tkn[:len]
          else
            advance_right
            @tokens[@right] = tkn
            @sizes[@right]  = tkn[:len]
            @right_total   += tkn[:len]
            check_stream
          end
      end
    end

    def check_stream
      if @right_total - @left_total > @space
        @sizes[scan_pop_bottom] = 900 if !@scan_stack_empy && !!@scan_stack[@bottom]
        advance_left @tokens[@left], @sizes[@left]
        check_stream if !(@left == @right)
      end
    end

    def scan_push x
      if @scan_stack_empy then @scan_stack_empy = false
      else
        @top = (@top + 1) % @scan_stack.length
        raise 'Scan Stack Full!' if @top == @bottom
      end
      @scan_stack[@top] = x
    end

    def scan_pop
      raise 'Scan Stack Empty!' if @scan_stack_empy
      res = @scan_stack[@top]
      if @top == @bottom then @scan_stack_empy = true
      else @top = (@top + @scan_stack.length - 1) % @scan_stack.length
      end
      res
    end

    def scan_top
      raise 'Scan Stack Empty!' if @scan_stack_empy
      @scan_stack[@top]
    end

    def scan_pop_bottom
      raise 'Scan Stack Empty!' if @scan_stack_empy
      res = @scan_stack[@bottom]
      if @top == @bottom then @scan_stack_empy = true
      else @bottom = (@bottom + 1) % @scan_stack.length
      end
      res
    end

    def advance_right
      @right = (@right + 1) % @scan_stack.length
      raise 'Token Queue Full!' if @right == @left
    end

    def advance_left x, l
      if l >= 0
        print_stack_print x, l
        case x[:type]
        when :break
          @left_total += x[:len]
        when :string
          @left_total += l
        end
        if @left != @right
          @left = (@left + 1) % @scan_stack.length
          advance_left @tokens[@left], @sizes[@left]
        end
      end
    end

    def check_stack k
      if !@scan_stack_empy
        x = scan_top
        case @tokens[x][:type]
          in :begin
            if k > 0
              @sizes[scan_pop] = @sizes[x] + @right_total
              check_stack k - 1
            end
          in :end
            @sizes[scan_pop] = 1
            check_stack k + 1
          else
            @sizes[scan_pop] = @sizes[x] + @right_total
            check_stack k if k > 0
        end
      end
    end

    def print_newline amount
      # TODO: make it more generic by writing to a stream
      @output.write "\n"
      indent amount
    end

    def indent amount
      amount.times do @output.write ' ' end
    end


    def print_stack_print tkn, l
      case tkn[:type]
        in :begin
          if l > @space
            break_kind = tkn[:kind] == :consistent ? :consistent : :inconsistent
            @print_stack.push({ offset: @space - tkn[:offset], kind: break_kind })
          else
            @print_stack.push({ offset: 0, kind: :fits })
          end
        in :end
          @print_stack.pop
        in :break
          top = @print_stack[-1]
          case top[:kind]
            in :fits
              @space -= tkn[:len]
              indent tkn[:len]
            in :consistent
              @space = top[:offset] - tkn[:offset]
              print_newline @margin - @space
            in :inconsistent
              if l > @space
                @space = top[:offset] - tkn[:offset]
                print_newline @margin - @space
              else
                @space -= tkn[:len]
                indent tkn[:len]
              end
          end
        in :string
          raise 'Line too Long!' if l > @space
          @space -= l
          @output.write tkn[:str]
      end
    end
  end
end
