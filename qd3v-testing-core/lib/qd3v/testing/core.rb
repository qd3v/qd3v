require 'qd3v-core'

ENV_BANG.config do
  use :APP_TEST_COVERAGE, class: :boolean, default: false
end

module Qd3v
  module Testing
    module Core
      class Container < Dry::System::Container
        import(from: Qd3v::Core::Container, keys: %w[logger env], as: :core)

        use :env, inferrer: -> { ENV! }
        use :zeitwerk, debug:      ENV['ZEITWERK_DEBUG'],
                       eager_load: ENV!.prod? || ENV['APP_TEST_COVERAGE']

        configure do |config|
          config.inflector = Dry::Inflector.new do |inflections|
          end

          config.name = :testing_core
          config.root = __dir__
          config.component_dirs.add('core') do |dir|
            dir.memoize = true
            dir.namespaces.add_root(const: "qd3v/testing/core")
          end
        end
      end

      DI = Container.injector.freeze
      Container.finalize!

      at_exit do
        Container.shutdown! # Call #shutdown on all providers
      end
    end
  end
end
