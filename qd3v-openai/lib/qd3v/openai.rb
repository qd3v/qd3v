require 'dry/struct'
require 'qd3v/core'

ENV_BANG.config do |c|
  c.use :QD3V_OPENAI_TOKEN
  c.use :QD3V_OPENAI_ORG_ID
  c.use :QD3V_OPENAI_MAX_RETRY, class: Integer, default: 8
  c.use :QD3V_OPENAI_FARADAY_LOG_DEBUG, class: :boolean, default: false
end

#
# DI
#

Dry::System.register_provider_sources(File.join(__dir__, 'providers'))

#
# MAIN
#

module Qd3v
  module OpenAI
    # Namespacing EK: this maps to correct i18n error keys
    EK = Class.new(Qd3v::Core::EK)

    # If user didn't provide own configuration, use default
    # NOTE: Call DI#finalize! if you rely on defaults
    DI.register_provider_with_defaults(:openai_client, from: :qd3v_openai)

    INFLECTIONS = {'openai' => 'OpenAI'}.freeze

    def self.loader
      @loader ||= Zeitwerk::Loader.for_gem_extension(Qd3v).tap do
        it.enable_reloading if ENV!.dev?
        it.log! if ENV['ZEITWERK_DEBUG']

        root = File.expand_path("..", __dir__)

        it.ignore(
          "#{root}/qd3v-openai.rb",
          "#{root}/qd3v/i18n",
          "#{root}/qd3v/providers",
          "#{root}/qd3v/openai_patch.rb")

        it.inflector.inflect(INFLECTIONS)
      end
    end

    loader.setup

    def self.eager_load!
      $stderr.puts("[EAGER LOADING] #{self}")
      loader.eager_load
    end

    eager_load! if ENV!.live? || ENV![:APP_EAGER_LOAD]

    # This one is to support underscore for i18n's const->key
    # REVIEW: is there a better way and rely only on ZW? I found only Inflector#capitalize
    ActiveSupport::Inflector.inflections do |inflect|
      INFLECTIONS.values.each { inflect.acronym it }
    end
  end

  Qd3v.load_i18n(__dir__)
end
