module Qd3v
  module OpenAI
    # What this class family is responsible for
    # - accepts some sort of objects??? trans
    # - use Client to send request
    class Command
      include SemanticLogger::Loggable
      include DI[client: :openai_client]

      protected

      def handle_response(err_kind: ErrKind::RESPONSE_ERROR)
        Try[Faraday::Error] {
          yield.then do |response_body|
            logger.trace { {message: "Got response", response_body:} }
            response_body
          end
        }.to_result.or do |exception|
          Err[err_kind, binding:, exception:, context:
            {response_body:   exception.response_body,
             response_status: exception.response_status}]
        end
      end
    end
  end
end
