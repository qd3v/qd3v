module Qd3v
  module OpenAI
    module Assistants
      module Commands
        class Find < Command
          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          #
          # @param id [String] The ID of the assistant to retrieve.
          # @return [Dry::Monads::Result::Success<Qd3v::OpenAI::OAI::Structs::Assistant>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(id:)
            T.assert_type!(id, String)

            handle_response(err_kind: ErrKind::ASSISTANT_NOT_FOUND) do
              client.assistants.retrieve(id:)
            end.fmap { Structs::Assistant.new(**it) }
          end
        end
      end
    end
  end
end
