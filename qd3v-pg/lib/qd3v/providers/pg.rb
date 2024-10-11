# NOTE: there's `log_errors:` client option, which is useless: lot logs to `Logger.new($stdout)`
#       and there's no way to substitute logger
# NOTE: As for default for env vars (if not set), look for gem's entrypoint file
Dry::System.register_provider_source(:pg, group: :qd3v_pg) do
  setting :uri,
          default:     ENV![:QD3V_PG_URI],
          constructor: Types::Strict::String

  prepare do
    require 'pg'
  end

  start do
    logger = target[:logger]
    uri    = URI(config[:uri])

    env      = ENV!.name.upcase
    host     = uri.host.presence || "localhost"
    database = uri.path.to_s.delete_prefix('/')

    ::PG.connect(uri).tap do
      $stderr.printf("[PG/%<env>s] Connected to '%<host>s/%<database>s'\n",
                     {env:, host:, database:})
    end.then { register(:pg, it) }
        .tap { logger.debug { {message: "PG client provider started"} } }
  end

  stop do
    target[:logger].debug { {message: "[PG] Closing connection..."} }
    container[:pg].close
  end
end
