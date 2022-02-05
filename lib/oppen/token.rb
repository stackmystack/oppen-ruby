module Oppen
  module Token
    # Integer.Max really
    # In the original paper it's set to 127
    MAX_BLANKS = (2**(0.size * 8 - 2) - 1)

    def self.eof
      { type: :eof }
    end

    def self.break(offset: 0, len: 1)
      {}.tap do |h|
        h[:type]   = :break
        h[:len]    = len    # Nº of spaces per blank
        h[:offset] = offset # Indent for overflow lines
      end
    end

    def self.end
      { type: :end }
    end

    def self.nl(offset = 0)
      self.break(offset: offset, len: MAX_BLANKS)
    end

    def self.begin(offset: 2, kind: :inconsistent)
      {}.tap do |h|
        h[:type]   = :begin
        h[:offset] = offset
        h[:kind]   = kind
      end
    end

    def self.string(str, len: str.size)
      {}.tap do |h|
        h[:type] = :string
        h[:str]  = str
        h[:len]  = len
      end
    end
  end
end
