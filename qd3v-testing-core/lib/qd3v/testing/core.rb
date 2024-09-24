require 'qd3v/core'

ENV_BANG.config do
  use :APP_TEST_COVERAGE, "Triggers eager load of tested app too",
      class: :boolean, default: false
end

Dry::System.register_provider_sources(File.join(__dir__, 'providers'))

#
# MAIN
#

module Qd3v
  # If user didn't provide own configuration, use default
  # NOTE: Call DI#finalize! if you rely on defaults
  #
  # If you need webmock/vcr, add
  #
  # @example
  #   Qd3v::DI.class_eval do
  #     register_provider(:webmock, from: :qd3v_testing_core)
  #     register_provider(:vcr, from: :qd3v_testing_core)
  #   end

  DI.register_provider_with_defaults(:rspec, from: :qd3v_testing_core)

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
    end
  end
end
