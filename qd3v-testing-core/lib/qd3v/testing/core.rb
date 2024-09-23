require 'qd3v/core'

ENV_BANG.config do
  use :APP_TEST_COVERAGE, "Triggers eager load of tested app too",
      class: :boolean, default: false
end

Dry::System.register_provider_sources(File.join(__dir__, 'providers'))

module Qd3v
  module Testing
    module Core
      def self.loader
        @loader ||= Zeitwerk::Loader.for_gem_extension(Qd3v::Testing).tap do
          it.log! if ENV['ZEITWERK_DEBUG']

          root = File.expand_path("..", __dir__)

          it.ignore(
            "#{root}/qd3v-testing-core.rb",
            "#{root}/qd3v/testing/providers")
        end
      end

      loader.setup

      class Container < Dry::System::Container
        register_provider(:logger, from: :qd3v_core)
      end

      DI = Container.injector.freeze

      at_exit { Container.shutdown! }
    end
  end
end
