module Qd3v
  class Err
    extend Forwardable
    include Enumerable

    DEFAULT_HTTP_STATUS_CODE = 500

    # Stolen from `Rack::Utils::HTTP_STATUS_CODES` to not depend on rack gem
    HTTP_STATUS_CODES =
      if defined?(Rack)
        Rack::Utils::HTTP_STATUS_CODES
      else
        {100 => 'Continue',
         101 => 'Switching Protocols',
         102 => 'Processing',
         103 => 'Early Hints',
         200 => 'OK',
         201 => 'Created',
         202 => 'Accepted',
         203 => 'Non-Authoritative Information',
         204 => 'No Content',
         205 => 'Reset Content',
         206 => 'Partial Content',
         207 => 'Multi-Status',
         208 => 'Already Reported',
         226 => 'IM Used',
         300 => 'Multiple Choices',
         301 => 'Moved Permanently',
         302 => 'Found',
         303 => 'See Other',
         304 => 'Not Modified',
         305 => 'Use Proxy',
         307 => 'Temporary Redirect',
         308 => 'Permanent Redirect',
         400 => 'Bad Request',
         401 => 'Unauthorized',
         402 => 'Payment Required',
         403 => 'Forbidden',
         404 => 'Not Found',
         405 => 'Method Not Allowed',
         406 => 'Not Acceptable',
         407 => 'Proxy Authentication Required',
         408 => 'Request Timeout',
         409 => 'Conflict',
         410 => 'Gone',
         411 => 'Length Required',
         412 => 'Precondition Failed',
         413 => 'Content Too Large',
         414 => 'URI Too Long',
         415 => 'Unsupported Media Type',
         416 => 'Range Not Satisfiable',
         417 => 'Expectation Failed',
         421 => 'Misdirected Request',
         422 => 'Unprocessable Content',
         423 => 'Locked',
         424 => 'Failed Dependency',
         425 => 'Too Early',
         426 => 'Upgrade Required',
         428 => 'Precondition Required',
         429 => 'Too Many Requests',
         431 => 'Request Header Fields Too Large',
         451 => 'Unavailable For Legal Reasons',
         500 => 'Internal Server Error',
         501 => 'Not Implemented',
         502 => 'Bad Gateway',
         503 => 'Service Unavailable',
         504 => 'Gateway Timeout',
         505 => 'HTTP Version Not Supported',
         506 => 'Variant Also Negotiates',
         507 => 'Insufficient Storage',
         508 => 'Loop Detected',
         511 => 'Network Authentication Required'}
      end

    # WARN: creation of Binding object is quite expensive. But for errors, I'm ok with that, and I
    # don't think it's more expensive than exception creation
    #
    # @param err_kind [Qd3v::Core::Ek] -> error code
    # @param binding [Binding] -> message to user
    # @param exception [NilClass,StandardError] exception instance which message will be added to errors[:exception]
    # @param errors [Hash<Symbol,String>] - The ActiveModel-style hash of errors. Push abstract to `base: ["test"]`
    # @param context [Hash] - anything useful for developers, or internal use
    # @param http_status [Integer] - server must know what to send
    def initialize(err_kind, binding:, exception: nil, errors: {}, context: {},
                   http_status: DEFAULT_HTTP_STATUS_CODE)
      T.assert_type!(err_kind, ::Qd3v::Core::EK)
      T.assert_type!(binding, ::Binding)

      T.assert_type!(errors, T::Hash[Symbol, T::Array[String]]) if errors.present?

      # NOTE: I don't think we ever need line num as a separate entity
      @err_kind    = err_kind
      @errors      = errors || {}
      @context     = context || {}
      @http_status = http_status
      @source      = binding.receiver.class.name

      # REVIEW: This exceptions handling addition is a WIP
      # Processing exception info
      unless exception.nil?
        unless exception.is_a?(StandardError)
          raise ArgumentError, "Argument `exception` should be really exception"
        end

        loc                   = exception&.backtrace_locations&.first
        # return blank string for file_line we check later if build successfully
        @file_path            = loc&.path
        @file_line            = [@file_path, loc&.lineno].compact.join(':')
        @exception            = exception
        @exception_class      = exception&.class
        @exception_class_name = exception&.class&.name
        @exception_message    = exception&.message

      end

      # No exception or can't get location correctly (is that even possible?)
      if @file_line.blank?
        @file_path, line = binding.source_location
        @file_line       = [@file_path, line].join(':')
      end

      self.class.broadcast(self)
    end

    def self.[](kind, **args)
      new(kind, **args).tap { yield it if block_given? }.to_failure
    end

    attr_reader :err_kind, :exception, :exception_message, :exception_class, :exception_class_name,
                :errors, :context, :source, :file_path, :file_line

    def http_status
      @http_status || DEFAULT_HTTP_STATUS_CODE
    end

    def http_status_description
      @http_status_description ||= HTTP_STATUS_CODES[http_status]
    end

    # NOTE: I think we shouldn't compact here, let pattern matching work
    def to_public
      @to_public ||= {message:, message_i18n_key:, err_kind:, errors:,
                      http_status:, http_status_description:}
    end

    def to_h
      @to_h ||=
        to_public.merge(context:, source:,
                        exception:,
                        exception_class:,
                        exception_class_name:,
                        exception_message:,
                        file_path:, file_line:)
    end

    # @example
    #   failure =>  Failure(err_kind: context: {a:}, errors:)
    # NOTE: there's another way: `Failure[err_kind, self]` below. Thus we can
    # do pattern matching this way `in Failure[Core::ErrKind::DUMMY_ERROR, {context: {a:}, errors:}]`
    def to_failure
      @to_failure ||= Failure(self)
    end

    # @note Experiment/RFC (see note above)
    def to_array_failure
      Failure[err_kind, self]
    end

    def [](key)
      to_h[key]
    end

    def_delegator :to_h, :each

    def deconstruct
      [err_kind, to_h]
    end

    # https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html#label-Matching+non-primitive+objects-3A+deconstruct+and+deconstruct_keys
    def deconstruct_keys(_keys)
      to_h
    end

    def message
      err_kind.message
    end

    def message_i18n_key
      err_kind.key
    end

    def exceptional?
      @exception.present?
    end

    DEFAULT_SUBSCRIBER = lambda { |err|
      # NOTE: here we use the fact that Err already provide #message
      SemanticLogger[err.source].error do
        err.to_h.except(:source, :err_kind, :exception, :exception_class,
                        :message_i18n_key,
                        :http_status, :http_status_description,
                        :file_path).reject { _2.blank? }
      end
    }

    class << self
      def subscribers
        @subscribers ||= [DEFAULT_SUBSCRIBER]
      end

      # Should respond to #call(Err). See `DEFAULT_SUBSCRIBER` above
      def add_subscribers(subs)
        subscribers.concat(Array(subs))
      end

      def broadcast(ek)
        subscribers.each { it.call(ek) }
      end

      def clear_subscribers
        @subscribers = nil
      end
    end
  end
end
