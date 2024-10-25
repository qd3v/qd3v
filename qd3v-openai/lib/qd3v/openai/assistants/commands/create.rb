module Qd3v
  module OpenAI
    module Assistants
      module Commands
        class Create < Command
          # Create new assistant from Assistant struct
          #
          # @param [Qd3v::OpenAI::Structs::Assistant] assistant The Assistant
          # @return [Dry::Monads::Result::Success<Qd3v::OpenAI::OAI::Structs::Assistant>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(assistant:)
            handle_response(err_kind: ErrKind::ASSISTANT_CREATE_ERROR) do
              client
                .assistants
                .create(parameters: assistant.to_create_payload)
            end.fmap { Structs::Assistant.new(**it) }
          end
        end
      end
    end
  end
end
