module Qd3v
  module OpenAI
    module Threads
      module Commands
        class FindOrCreate < Command
          def initialize(cmd_find: Find.new, cmd_create: Create.new)
            @cmd_find   = cmd_find
            @cmd_create = cmd_create
          end

          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          # API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          # @param thread_id [String,NilClass] The ID of the assistant to retrieve.

          # @return [Dry::Monads::Result::Success<Structs::Thread>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.

          def call(id:)
            T.assert_type!(id, T.nilable(String))

            id.presence.tap do
              it ? @cmd_find.call(id:).alt_map { @cmd_create.call } : @cmd_create.call
            end
          end
        end
      end
    end
  end
end
