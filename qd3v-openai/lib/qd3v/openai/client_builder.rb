module Qd3v
  module OpenAI
    # What this class is responsible for
    # - API abstraction: single point of entry
    # - accepts only scalar/hash values
    # - logs what's happening
    # - this class only help is to configure client for us
    #
    # NOTE: We can cache this
    class ClientBuilder
      include SemanticLogger::Loggable

      def initialize(env: ENV_BANG)
        @env = env
      end

      def call
        @client ||= build.tap { logger.debug { "OAI client build" } }
      end

      private

      def build
        logger.debug { "Initializing OAI client" }

        ::OpenAI::Client.new(access_token:    @env[:QD3V_OPENAI_TOKEN],
                             organization_id: @env[:QD3V_OPENAI_ORG_ID],
                             log_errors:      true) do |f|
          f.request :retry,
                    max:                 @env[:QD3V_OPENAI_MAX_RETRY],
                    interval:            0.5,
                    interval_randomness: 0.5,
                    backoff_factor:      2,
                    exceptions:          [Faraday::ServerError]

          f.response :json, parser_options: {symbolize_names: true}
        end
      end
    end
  end
end
