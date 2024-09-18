module Qd3v
  # TODO: Split to :webmock, :vcr and probably :simplecov providers. Start this as dep
  Testing::Core::Container.register_provider(:rspec) do
    setting :coverage_enabled,
            default:     ENV![:APP_TEST_COVERAGE],
            constructor: Types::Strict::Bool

    setting :coverage_dir,
            default:     File.join(Dir.pwd, ".coverage"),
            constructor: Types::Strict::String

    prepare do
      require 'rspec'
      require 'active_support/testing/time_helpers'
      require 'json_expressions/rspec'
      require 'super_diff/rspec'
      require "webmock/rspec"
      require "vcr"

      require('simplecov') if config[:coverage_enabled]
    end

    start do
      logger = target['core.logger']
      logger.debug { "Loading RSpec config (core)..." }

      # COVERAGE

      if config[:coverage_enabled]
        logger.warn { "Test coverage enabled!" }

        SimpleCov.coverage_dir(config[:coverage_dir])

        # REVIEW: pass config block as setting?
        # NOTE: In order this to truly track ALL files, and not only loaded,
        # container's eager load must be enabled
        # https://github.com/simplecov-ruby/simplecov?tab=readme-ov-file#primary-coverage
        SimpleCov.start do
          enable_coverage :branch
          primary_coverage :branch
          add_filter %r{^/(spec|vendor)/}
          add_filter %r{/dummy\.rb\z}
        end
      end

      VCR.configure do |config|
        config.cassette_library_dir = "spec/vcr"
        config.hook_into :webmock
      end

      # RSPEC BASICS

      RSpec.configure do |config|
        config.expose_dsl_globally                  = false
        config.fail_if_no_examples                  = true
        config.example_status_persistence_file_path = "tmp/spec_example_status.txt"
        config.disable_monkey_patching!

        config.alias_example_to :request_result

        config.profile_examples  = 15 if ENV['APP_TEST_PROFILE']
        config.default_formatter = 'doc' if config.files_to_run.one?

        # MOCK

        config.mock_with :rspec do |mocks|
          # This option should be set when all dependencies are being loaded
          # before a spec run, as is the case in a typical spec helper. It will
          # cause any verifying double instantiation for a class that does not
          # exist to raise, protecting against incorrectly spelt names.
          mocks.verify_doubled_constant_names = true

          # https://rspec.info/features/3-12/rspec-mocks/verifying-doubles/partial-doubles/
          mocks.verify_partial_doubles = true
        end

        #
        # FILTERING
        #

        config.run_all_when_everything_filtered = true

        if ENV['APP_TEST_FORCE_ALL'] == 1
          # this MAY override CLI args
          # config.filter_run_including(nil)
          # this WILL override CLI args
          config.inclusion_filter = nil
        end

        #
        # MODULES
        #

        config.include(Module.new do
          define_method(:logger) do
            @logger = logger
          end
        end)

        config.include ActiveSupport::Testing::TimeHelpers

        #
        # HOOKS
        #

        config.before(:each) do |_ex|
          logger.info(">>>> EXAMPLE STARTED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        end

        config.after(:each) do
          logger.info("<<<< EXAMPLE ENDED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end
      end

      register(:rspec_loaded, true)
      register(:rspec, RSpec.configuration)
    end

    stop do
    end
  end
end
