module Qd3v
  module Core
    # Holds i18n for err_kind
    #
    # @example
    #   module A
    #     class EK < Qd3v::Core::EK; end
    #
    #     module ErrKind
    #       PROBLEM = EK[:problem] # i18n: en.a.err_kind.problem
    #     end
    #   end
    #
    class EK
      # @param [Symbol] err_kind
      def initialize(err_kind)
        @err_kind = err_kind
      end

      attr_reader :err_kind

      # Raises I18n::MissingTranslationData
      def message(locale: 'en')
        I18n.t(key, locale:, raise: true)
      end

      def key
        @key ||= "#{namespace}.err_kind.#{err_kind}"
      end

      alias to_s key
      alias inspect key

      # NOTE: i18n will prepend `<lang>`
      # Example `Qd3v::Services::EK` -> `qd3v.services`
      # Example `Qd3v::Services::HTTP::EK` -> `qd3v.services.http`
      def namespace
        # NOTE: here we drop EK part using range
        @namespace ||= infer_namespace.tap do |ns|
          if ns.end_with?('.ek')
            raise NotImplementedError,
                  'EK class: you forgot to subclass me in your namespace'
          end
        end
      end

      def self.[](err_kind)
        new(err_kind)
      end

      private

      # Handle class QFN to i18n key translation using Zeitwerk inflection rules
      def infer_namespace
        # Basically re-build each const name, then convert to underscore
        self.class.name.split('::')[...-1].map do
          inflector.camelize(it.downcase, nil).underscore
        end.join('.')
      end

      def inflector
        Zeitwerk::Inflector.new
      end
    end
  end
end
