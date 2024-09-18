module Qd3v
  module Core
    class EK
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

      # NOTE: i18n will prepend `<lang>`
      # Example `Qd3v::Services::EK` -> `qd3v.services`
      # Example `Qd3v::Services::HTTP::EK` -> `qd3v.services.http`
      def namespace
        # NOTE: here we drop EK part using range
        @namespace ||= self.class.name.split('::')[...-1].map(&:underscore).join('.').tap do |ns|
          if ns == 'ek'
            raise NotImplementedError,
                  'EK class: you forgot to subclass me in your namespace'
          end
        end
      end

      def self.[](err_kind)
        new(err_kind)
      end

      def to_s
        key
      end
    end
  end
end
