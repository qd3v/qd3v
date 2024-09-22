module Qd3v
  module OpenAI
    module Threads
      module Commands
        class FindOrCreate < Command
          def initialize(cmd_find: Find.new, cmd_create: Create.new, **k)
            super(**k)
            @cmd_find   = cmd_find
            @cmd_create = cmd_create
          end

          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          # API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          # @param thread_id [String] The ID of the assistant to retrieve.

          # @return [Dry::Monads::Result::Success<Structs::Thread>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.

          def call(id:)
            T.assert_type!(id, String)
            @cmd_find.call(id: )
                     .fmap { Structs::Thread.new(**_1) }
                     .alt_map { @cmd_create.call }
          end
        end
      end
    end
  end
end
