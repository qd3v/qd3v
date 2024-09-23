require 'dry/struct'
require 'qd3v/core'

ENV_BANG.config do |c|
  c.use :QD3V_OPENAI_TOKEN
  c.use :QD3V_OPENAI_ORG_ID
  c.use :QD3V_OPENAI_MAX_RETRY, class: Integer, default: 0
  c.use :QD3V_OPENAI_FARADAY_LOG_DEBUG, class: :boolean, default: false
  c.use :QD3V_OPENAI_TEST_COVERAGE, class: :boolean, default: false
end

Dry::System.register_provider_sources(File.join(__dir__, 'providers'))

module Qd3v
  module OpenAI
    def self.loader
      @loader ||= Zeitwerk::Loader.for_gem_extension(Qd3v).tap do
        it.enable_reloading if ENV!.dev?
        it.log! if ENV['ZEITWERK_DEBUG']
        it.eager_load if ENV!.prod? || ENV![:QD3V_OPENAI_TEST_COVERAGE]

        root = File.expand_path("..", __dir__)

        it.ignore(
          "#{root}/qd3v-openai.rb",
          "#{root}/qd3v/i18n",
          "#{root}/qd3v/providers")

        it.inflector.inflect('openai' => 'OpenAI')
      end
    end

    loader.setup

    class Container < Dry::System::Container
      register_provider(:logger, from: :qd3v_core)
      register_provider(:openai_client, from: :qd3v_openai)
    end

    DI = Container.injector.freeze

    at_exit { Container.shutdown! }
  end

  Qd3v.load_i18n(__dir__)
end
