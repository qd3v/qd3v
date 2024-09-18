require 'openai'
require 'faraday/retry'
require 'qd3v/core'
require 'dry/struct'

ENV_BANG.config do |c|
  c.use :QD3V_OPENAI_TOKEN
  c.use :QD3V_OPENAI_ORG_ID
  c.use :QD3V_OPENAI_MAX_RETRY, default: 0
end

module Qd3v
  module OpenAI
    class Container < Dry::System::Container
      import(from: Qd3v::Core::Container, keys: %w[config], as: :core)

      use :zeitwerk, debug:      ENV['ZEITWERK_DEBUG'],
                     eager_load: ENV!.prod? || ENV['QD3V_TEST_COVERAGE']

      configure do |config|
        config.inflector = Dry::Inflector.new do |inflections|
          inflections.acronym 'OpenAI'
        end

        config.name = :qd3v_openai
        config.root = __dir__
        config.component_dirs.add('openai') do |dir|
          dir.memoize = true
          dir.namespaces.add_root(const: "qd3v/openai")
        end
      end
    end

    Container.register(:env, ENV_BANG)

    DI = Container.injector.freeze

    if ENV!.test?
      require 'dry/system/stubs'
      Container.enable_stubs!
    else
      Container.finalize! unless ENV['APP_SKIP_FINALIZE']
    end

    at_exit do
      Container.shutdown! # Call #shutdown on all providers
    end
  end
end
