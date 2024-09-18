module Qd3v
  module OpenAI
    module Assistants
      module Commands
        class Update < Command
          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          #
          # @param [Qd3v::OpenAI::Structs::Assistant] assistant The Assistant
          # @return [Dry::Monads::Result::Success<Qd3v::OpenAI::OAI::Structs::Assistant>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(assistant:)
            handle_response(ErrKind::ASSISTANT_UPDATE_ERROR) do
              client
                .assistants
                .modify(id: assistant.id, parameters: assistant.to_update_payload)
            end.fmap { Structs::Assistant.new(**_1) }
          end
        end
      end
    end
  end
end
