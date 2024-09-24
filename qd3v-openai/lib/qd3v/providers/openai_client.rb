# NOTE: there's `log_errors:` client option, which is useless: lot logs to `Logger.new($stdout)`
#       and there's no way to substitute logger
Dry::System.register_provider_source(:openai_client, group: :qd3v_openai) do
  setting :access_token,
          default:     ENV![:QD3V_OPENAI_TOKEN],
          constructor: Types::Strict::String

  setting :organization_id,
          default:     ENV![:QD3V_OPENAI_ORG_ID],
          constructor: Types::Strict::String

  setting :max_retry,
          default:     ENV![:QD3V_OPENAI_MAX_RETRY],
          constructor: Types::Strict::Integer

  setting :faraday_log_debug,
          default:     ENV![:QD3V_OPENAI_FARADAY_LOG_DEBUG],
          constructor: Types::Strict::Bool

  prepare do
    require 'openai'
    require 'faraday/retry'
  end

  start do
    logger = target[:logger]

    OpenAI::Client.new(access_token:    config[:access_token],
                       organization_id: config[:organization_id]) do |f|
      f.request :retry,
                max:                 config[:max_retry],
                interval:            0.5,
                interval_randomness: 0.5,
                backoff_factor:      2,
                exceptions:          [Faraday::ServerError]
      f.request :json, encoder: Oj

      # There's only response logging middleware
      if config[:faraday_log_debug]
        f.response :logger, SemanticLogger['Faraday'], {
          headers: true, bodies: true, log_level: :debug}
      end

      f.response :json, parser_options: {decoder: Oj, symbolize_names: true}
    end.then { register(:openai_client, it) }
                  .tap { logger.debug { "OpenAI client provider started" } }
  end
end
