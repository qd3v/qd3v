module Qd3v
  # standard Error class
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
    def initialize(err_kind, binding:, exception: nil,
                   errors: {}, context: {},
                   http_status: DEFAULT_HTTP_STATUS_CODE)

      T.assert_type!(err_kind, ::Qd3v::Core::EK)
      T.assert_type!(binding, ::Binding)

      T.assert_type!(errors, T::Hash[Symbol, T::Array[String]]) if errors.present?
      T.assert_type!(context, T::Hash[Symbol, T.anything]) if context.present?

      # NOTE: I don't think we ever need line num as a separate entity
      @err_kind    = err_kind
      @errors      = errors.presence || {}
      @context     = context.presence || {}
      @http_status = http_status
      @source      = binding.receiver.class.name

      # Saving exception info
      # NOTE: Exception (if present) location usually point deeper than binding
      unless exception.nil?
        unless exception.is_a?(StandardError)
          raise ArgumentError, "Argument `exception` should be real exception"
        end

        loc                      = exception&.backtrace_locations&.first
        # return blank string for file_line we check later if build successfully
        @exception_file_path     = loc&.path
        @exception_file_line     = [@exception_file_path, loc&.lineno].compact.join(':')
        @exception               = exception
        @exception_class         = exception&.class
        @exception_class_name    = exception&.class&.name
        @exception_message       = exception&.message
        @exception_cause         = exception&.cause
        @exception_cause_message = exception&.cause&.message
      end

      @file_path, line = binding.source_location
      @file_line       = [@file_path, line].join(':')

      self.class.broadcast(self)
    end

    def self.[](kind, **args)
      new(kind, **args).tap { yield it if block_given? }.to_failure
    end

    attr_reader :err_kind, :errors, :context, :source, :file_path, :file_line,
                :exception, :exception_message, :exception_class, :exception_class_name,
                :exception_cause, :exception_cause_message, :exception_file_path, :exception_file_line

    def http_status
      @http_status || DEFAULT_HTTP_STATUS_CODE
    end

    def http_status_description
      @http_status_description ||= HTTP_STATUS_CODES[http_status]
    end

    # I think we shouldn't compact here, let pattern matching work
    def to_public
      @to_public ||= {message:, message_i18n_key:, err_kind:, errors:,
                      http_status:, http_status_description:}
    end

    # All known information (not intended to leak to public)
    def to_h
      @to_h ||=
        to_public.merge(context:,
                        source:,
                        file_path:,
                        file_line:,
                        exception:,
                        exception_class:,
                        exception_class_name:,
                        exception_message:,
                        exception_cause:,
                        exception_cause_message:,
                        exception_file_path:,
                        exception_file_line:)
    end

    def to_h_compact
      @to_h_compact ||= to_h.compact
    end

    # TODO: Move SML stuff out from here
    # Context is reserved keyword in SML payload (`payload` is too, btw)
    SEMANTIC_LOGGER_KEYS = %i[message
                              err_kind
                              exception_message
                              exception_cause_message
                              errors context
                              file_line
                              exception_file_line]

    SEMANTIC_LOGGER_COMP_KEYS_REMAPPING = {context: :err_context}
    SEMANTIC_LOGGER_SUBSCRIBER          = ->(err) {
      SemanticLogger[err.source].error { err.to_semantic_log_entry }
    }

    def to_semantic_log_entry
      # Here we use the fact that Err already provide :message key
      @to_semantic_log_entry ||=
        to_h_compact
          .slice(*SEMANTIC_LOGGER_KEYS)
          .transform_keys(SEMANTIC_LOGGER_COMP_KEYS_REMAPPING)
    end

    INSPECT_KEYS = %i[message exception_message exception_cause_message err_kind errors
                      context].freeze

    def inspect
      @inspect ||= self.class.name + to_h_compact.slice(*INSPECT_KEYS).inspect
    end

    # To fully comply with Exception interface (it expects `to_str` for anything passed as message
    # to constructor), adding this method, which is used for implicit conversion to String (e.g.
    # `String.new(x).length`). Anyway, there is the difference, and these methods can return
    # different results, but making code more unpredictable :(

    # Docs: https://ruby-doc.org/3.4.0.preview2/implicit_conversion_rdoc.html#label-String-Convertible+Objects
    alias to_str inspect
    # This one is called in strings interpolation, puts x (which looks like implicit, btw), etc
    alias to_s inspect

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

    class << self
      # TODO: This is designed to be configurable
      def subscribers
        @subscribers ||= [SEMANTIC_LOGGER_SUBSCRIBER]
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
