module Qd3v
  module OpenAI
    # What this class family is responsible for
    # - accepts some sort of objects??? trans
    # - use Client to send request
    class Command
      include SemanticLogger::Loggable

      def initialize(client_builder: ClientBuilder.new)
        @client_builder = client_builder
      end

      protected

      def handle_response(err_kind = ErrKind::RESPONSE_ERROR)
        Try {
          yield.then do |response_body|
            logger.trace { {message: "Got response", response_body:} }
            response_body
          end
        }.to_result.or do |exception|
          Err[err_kind, binding:, exception:, context: {
            response_body:   e.response_body,
            response_status: e.response_status}]
        end
      end

      def client
        @client ||= @client_builder.call
      end
    end
  end
end
