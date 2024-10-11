module Qd3v
  # See spec for rationale
  class UnexpectedErr < StandardError
    def initialize(err)
      T.assert_type!(err, Qd3v::Err)

      @cause = err.exceptional? ? err.exception : nil

      super("Got Unexpected Err object: #{err.inspect}")
    end

    attr_reader :cause
  end
end
