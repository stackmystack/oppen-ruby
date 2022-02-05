# frozen_string_literal: true

require_relative 'helpers'

module Oppen
  describe 'Test string printing' do
    before do
      @cfg = {
        margin: 79,
        offset: 2,
        output: StringIO.new
      }
    end

    it 'should print ASCII' do
      str = 'print me'
      tkn = Token.string str
      pp  = Printer.new(**@cfg)

      pp.pretty_print tkn

      assert_equal str, @cfg[:output].string
    end

    it 'should print emojis' do
      str = 'print me 🙋‍♂️'
      tkn = Token.string str
      pp  = Printer.new(**@cfg)

      pp.pretty_print tkn

      assert_equal str, @cfg[:output].string
    end
  end

  describe 'Test break' do
    before do
      @tokens = [
        Token.begin,
        Token.string('Hello'),
        Token.break,
        Token.string('World!'),
        Token.end,
        Token.eof
      ]
    end

    it 'should not break when margin is large enough' do
      cfg = {
        margin: 79,
        offset: 2,
        output: StringIO.new
      }
      expected = 'Hello World!'

      pp = Printer.new(**cfg)

      @tokens.each do |tkn|
        pp.pretty_print tkn
      end

      assert_equal expected, cfg[:output].string
    end

    it 'should break when margin is tight' do
      cfg = {
        margin: 10,
        offset: 2,
        output: StringIO.new
      }
      expected = "Hello\n  World!"

      pp = Printer.new(**cfg)

      @tokens.each do |tkn|
        pp.pretty_print tkn
      end

      assert_equal expected, cfg[:output].string
    end
  end

  describe 'Test offset' do
    before do
      @cfg = {
        margin: 10,
        offset: 2,
        output: StringIO.new
      }
      @pp = Printer.new(**@cfg)
    end

    def make_tokens(offset = 2)
      tokens = [
        Token.begin(offset: offset),
        Token.string('Hello'),
        Token.break,
        Token.string('World!'),
        Token.end,
        Token.eof
      ]
      expected = +"Hello\n"
      expected << (' ' * offset)
      expected << 'World!'

      [tokens, expected]
    end

    def assert_correct_offset(offset)
      tokens, expected = make_tokens(offset)

      tokens.each do |tkn|
        @pp.pretty_print tkn
      end

      assert_equal expected, @cfg[:output].string
    end

    it 'should indent offset by 2' do
      assert_correct_offset(2)
    end

    it 'should indent offset by 4' do
      assert_correct_offset(4)
    end

    it 'should indent offset by 6' do
      assert_correct_offset(4)
    end
  end

  describe 'Test nested blocks' do
    it 'should handle nested blocks nicely' do
      cfg = {
        margin: 79,
        offset: 2,
        output: StringIO.new
      }
      pp = Printer.new(**cfg)
      expected = <<~MAYBE_PASCAL.chomp
        procedure test(x, y: Integer);
        begin
          x:=1;
          y:=200;
          for z:= 1 to 100 do
          begin
            x := x + z;
          end;
          y:=x;
        end;
      MAYBE_PASCAL

      tokens = [
        Token.begin(offset: 0, kind: :consistent),
        Token.string('procedure test(x, y: Integer);'), Token.nl,
        Token.string('begin'),
        Token.nl(2), Token.string('x:=1;'),
        Token.nl(2), Token.string('y:=200;'),

        Token.nl(2),
        Token.begin(offset: 0, kind: :consistent),
        Token.string('for z:= 1 to 100 do'), Token.nl,
        Token.string('begin'),
        Token.nl(2), Token.string('x := x + z;'), Token.nl,
        Token.string('end;'),
        Token.end,

        Token.nl(2), Token.string('y:=x;'), Token.nl,
        Token.string('end;'),

        Token.end,
        Token.eof
      ]

      tokens.each do |tkn|
        pp.pretty_print tkn
      end

      assert_equal expected, cfg[:output].string
    end
  end
end
