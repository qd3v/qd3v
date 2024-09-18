# RUBY STDLIB

require 'pathname'

#
# ACTIVE SUPPORT
#

# This first loads only minimum for cherry-picking to work
require 'active_support'
require 'active_support/core_ext/hash/keys' # deep_symbolize
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters' # squish
require 'active_support/core_ext/string/inflections' # titlecase, constantize
require 'active_support/concern'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/time/calculations'

#
# CORE GEMS
#

require 'zeitwerk'
require 'sorbet-runtime'
require 'semantic_logger'
require 'ruby-enum'

require 'dry/monads'
require 'dry/system'
require 'dry/initializer'
require 'dry/configurable'

include Dry::Monads[:result, :maybe, :try, :list] # Making monads classes globally accessible

#
# REVIEW: Don't depend on gems not used
#

require 'dry/schema'
require 'dry/validation'

Dry::Validation.load_extensions(:monads)
Dry::Schema.load_extensions(:json_schema)

# NOTE: This adds #to_json methods, we don't need to use AS extension
# IMPORTANT: If we add default option do symbolize keys, that may break app third-party gems, expecting string keys
# Docs: https://github.com/ohler55/oj/blob/develop/pages/Options.md
require 'oj'
Oj.mimic_JSON

#
# LOADING ENV + ENVBANG
#

# env loading. In production (containers build) we use this to load release env vars from .env.local file
# NOTE: there's a build-in reader from env files and vars: https://github.com/dry-rb/dry-system/tree/main/lib/dry/system/provider_sources
require_relative 'load_env'
require_relative 'env_bang'
require_relative 'config'

require_relative 'types' # common and custom types
require_relative 'err' # standard Error class
require_relative 'ek' # error kind build helper

# Providers from system/providers are loaded automatically
module Qd3v
  module Core
    class Container < Dry::System::Container
      # Env plugin: just a helper
      use :env, inferrer: -> { ENV! }
      use :zeitwerk, debug:      ENV['ZEITWERK_DEBUG'],
                     eager_load: ENV!.prod? || ENV['QD3V_TEST_COVERAGE']

      # use :settings

      configure do |config|
        config.inflector = Dry::Inflector.new do |inflections|
          inflections.acronym('FS')
          inflections.acronym('OAI')
          inflections.acronym('TTS')
          inflections.acronym('HTTP')
          inflections.acronym('XML')
          inflections.acronym('JS')
          inflections.acronym('AE')
          inflections.acronym('AI')
        end

        config.name = :qd3v_core
        config.root = __dir__
        config.component_dirs.add('core') do |dir|
          dir.memoize = true
          dir.namespaces.add_root(const: 'qd3v/core')
        end
      end

      register(:env, ENV_BANG)
    end

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

  def self.load_i18n(root_dir)
    files           = Dir[File.join(root_dir, "i18n", "*.yml")]
    I18n.load_path += files
  end

  load_i18n(__dir__)
end
