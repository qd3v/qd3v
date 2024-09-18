module Qd3v
  module OpenAI
    module Threads
      module Commands
        class Find < Command
          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          # API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          # @param id [String] The ID of the assistant to retrieve.
          # @return [Dry::Monads::Result::Success<Structs::Thread>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.

          def call(id:)
            T.assert_type!(id, String)

            handle_response(ErrKind::THREAD_NOT_FOUND) do
              client.threads.retrieve(id:)
            end.fmap { Structs::Thread.new(**_1) }
          end
        end
      end
    end
  end
end
