module Qd3v
  module OpenAI
    module Threads
      module Commands
        class FindOrCreate < Command
          def initialize(cmd_find: Find.new, cmd_create: Create.new)
            @cmd_find   = cmd_find
            @cmd_create = cmd_create
          end

          # @return [Success<Structs::Thread>, Failure] The retrieved assistant wrapped in a
          #   Success. In case of an error, the method will return a Failure monad.

          def call(id:)
            T.assert_type!(id, T.nilable(String))

            id.presence.then do
              it ? @cmd_find.call(id:).or { @cmd_create.call } : @cmd_create.call
            end
          end
        end
      end
    end
  end
end
