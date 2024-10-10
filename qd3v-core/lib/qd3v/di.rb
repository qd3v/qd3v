module Qd3v
  # Small extension for `Dry::System::Container` that let gem's providers to be still registered if
  # user didn't provide own registration and configuration.
  #
  # Example: if no change in logger conf required, user can skip explicit registration of :logger
  # provider in system But, we can't tell if user did that until we finalize container, so the best
  # way I found is to hook in to finalization process, thanks to this method's design we can add
  # last-moment adjustments by passing block
  #
  # Reminder: provider starts only then provider is required by another component, is started
  # directly, or when the container finalizes.
  class DI < Dry::System::Container
    class << self
      def register_provider_with_defaults(name, from:)
        @provider_with_defaults       ||= {}
        @provider_with_defaults[name] = -> {
          register_provider(name, from:)
        }
      end

      def finalize!(freeze: true, &block)
        super do
          (@provider_with_defaults || {}).each do |name, proc|
            unless key?(name)
              $stderr.puts("[DI] Registering '#{name}' provider with defaults")
              proc.call
            end
          end

          yield(self) if block
        end
      end
    end
  end

  at_exit { DI.shutdown! }
end
