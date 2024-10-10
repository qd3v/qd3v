# RUBY STDLIB

require 'pathname'
require 'forwardable'

#
# ACTIVE SUPPORT
#

# This first loads only minimum required
require 'active_support'
require 'active_support/core_ext/hash/keys' # deep_symbolize
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters' # squish
require 'active_support/core_ext/string/inflections' # titleize, constantize
require 'active_support/concern'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/time/calculations'

#
# CORE GEMS TUNING
#

require 'sorbet-runtime'
require 'semantic_logger' # Eager load mode require `SemanticLogger::Loggable` to be defined

# Making monads globally accessible
require 'dry/monads'
include Dry::Monads[:result, :maybe, :try, :list]

# optimize_rails patch AS#to_json etc
# NOTE: This adds #to_json methods, we don't need to use AS extension
# WARN: If we add default option do symbolize keys, that may break app third-party gems, expecting string keys
# DOCS: https://github.com/ohler55/oj/blob/develop/pages/Options.md
#       https://github.com/ohler55/oj/blob/develop/pages/Rails.md
require 'oj'
Oj.optimize_rails

#
# LOADING ENV + ENVBANG
#

# env loading. In production (containers build) we use this to load release env vars from .env.local file
# NOTE: there's a build-in reader from env files and vars: https://github.com/dry-rb/dry-system/tree/main/lib/dry/system/provider_sources
# These are running in global namespace
require_relative 'global/env_bang'
require_relative 'global/load_env'
require_relative 'global/types'

# Updating EB config
ENV_BANG.config do |c|
  add_class :log_level do |value, options|
    if value.present?
      value.to_s.downcase.strip.to_sym
    else
      options.fetch(:default, :info)
    end
  end

  add_class :env do |value, *|
    value = begin
              value.to_s.to_sym
            rescue StandardError
              '<unparsable>'
            end

    return value if ENV_BANG.environments.include?(value)

    abort("[ENV] Unknown environment: APP_ENV='#{value}'")
  end

  c.use :APP_ENV, class: :env
  c.use :APP_LOG_LEVEL, class: :log_level, default: :info
  c.use :APP_LOG_TO_STDOUT, class: :boolean, default: true

  c.use :APP_EAGER_LOAD, class: :boolean, default: false
  c.use :APP_TEST_COVERAGE, class: :boolean, default: false
end

#
# DI
#

# Providers depend on Types defined (and altered ENV_BANG too)
# https://dry-rb.org/gems/dry-system/1.0/external-provider-sources/

require 'dry/system'
Dry::System.register_provider_sources(File.join(__dir__, 'providers'))

# DI.register_provider(:logger, from: :qd3v_core)

#
# MAIN
#

require_relative 'di' # This one goes to root `Qd3v` module
require_relative 'err' # This one goes to root `Qd3v` module

module Qd3v
  module Core
    # If user didn't provide own configuration, use default
    # NOTE: Call DI#finalize! if you rely on defaults
    DI.register_provider_with_defaults(:logger, from: :qd3v_core)

    def self.loader
      @loader ||= Zeitwerk::Loader.for_gem_extension(Qd3v).tap do
        it.enable_reloading if ENV!.dev?
        it.log! if ENV['ZEITWERK_DEBUG']

        root = File.expand_path("..", __dir__)

        it.ignore(
          "#{root}/qd3v-core.rb",
          "#{root}/qd3v/err.rb",
          "#{root}/qd3v/di.rb",
          "#{root}/qd3v/i18n",
          "#{root}/qd3v/global",
          "#{root}/qd3v/providers")

        it.inflector.inflect('ek' => 'EK')
      end
    end

    loader.setup

    def self.eager_load!
      $stderr.puts("[EAGER LOADING] #{self}")
      loader.eager_load
    end

    eager_load! if ENV!.live? || ENV![:APP_EAGER_LOAD]
  end

  def self.load_i18n(root_dir)
    files          = Dir[File.join(root_dir, "i18n", "*.yml")]
    I18n.load_path += files
  end

  load_i18n(__dir__)
end
