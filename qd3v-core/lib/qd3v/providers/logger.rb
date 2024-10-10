# NOTE: We have to use FQ names here because of block
# Types: https://dry-rb.org/gems/dry-types/1.7/built-in-types/
# Configurable: https://dry-rb.org/gems/dry-configurable/1.0/#usage

Dry::System.register_provider_source(:logger, group: :qd3v_core) do
  setting :level,
          default:     ENV![:APP_LOG_LEVEL],
          constructor: Types::Strict::Symbol

  setting :dir,
          default:     File.join(Dir.pwd, 'log'),
          constructor: -> { Pathname(it) }

  setting :default_name,
          default:     'main',
          constructor: Types::Nominal::String

  # Docs: https://logger.rocketjob.io/index.html
  # NOTE: You can customize each formatter passing more params,
  # see https://github.com/rocketjob/semantic_logger/tree/master/lib/semantic_logger/formatters

  prepare do
    # Just in case, should be already required in core.rb
    require 'semantic_logger'
  end

  start do
    # REVIEW: get back Core::Logging::Production.new ?
    # https://logger.rocketjob.io/filtering.html

    log_level = config[:level]
    log_env   = ENV!.name
    formatter = ENV!.live? ? :json : :color
    file_name = "$stdout"

    SemanticLogger.default_level = log_level

    if ENV!.live? || ENV!.dev?
      $stdout.sync

      SemanticLogger.add_appender(io: $stdout, formatter:)
    else
      log_dir   = config[:dir]
      file_name = log_dir.join("#{log_env}.log").to_s
      log_dir.mkpath unless log_dir.exist?

      SemanticLogger.add_appender(file_name:, formatter:)
    end

    $stderr.printf("[LOGGER/%s] Logging to '%s', formatter: %s, level: %s\n",
                   log_env.upcase, file_name, formatter, log_level)

    logger = SemanticLogger[config[:default_name]]

    register(:logger, logger).tap do
      logger.trace { {message: '[LOGGER] Logger started', config: config.to_h} }
    end
  end

  stop do
    logger.trace('[LOGGER] Closing logger...')
    container[:logger].close
  end
end
