module Qd3v
  module OpenAI
    module Threads
      module Commands
        class Create < Command
          # WARN: Once you create a thread, there is no way to list it
          # or recover it currently (as of 2023-12-10). So hold onto the `id`
          #
          # API: https://platform.openai.com/docs/api-reference/threads/createThread
          # Gem API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          #
          # @return [Dry::Monads::Result::Success<Structs::Thread>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call
            handle_response(err_kind: ErrKind::THREAD_CREATION_ERROR) do
              # Everything is optional here, passing nothing
              client.threads.create
            end.fmap { Structs::Thread.new(**_1) }
          end
        end
      end
    end
  end
end
