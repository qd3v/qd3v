module Qd3v
  module OpenAI
    module Runs
      module Commands
        class Create < Command
          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          # API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          # @param [String] assistant_id The ID of the assistant
          # @param [String] thread_id The ID of the thread
          # @param [Boolean] streaming
          # @return [Dry::Monads::Result::Success<Structs::Run>, Dry::Monads::Result::Failure] The
          # retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(assistant_id:, thread_id:, additional_instructions: nil, streaming: true)
            T.assert_type!(assistant_id, String)
            T.assert_type!(thread_id, String)
            T.assert_type!(additional_instructions, T.nilable(String))
            T.assert_type!(streaming, T::Boolean)

            lines  = ''
            stream = if streaming
                       # TODO: const
                       proc do |chunk, _bytesize|
                         if chunk['object'] == 'thread.message.delta'
                           lines << chunk.dig('delta', 'content', 0, 'text', 'value')
                         end
                       end
                     end

            # NOTE: here we get plain string response because of streaming
            # REVIEW: One downside: we've got no stats or other stuff completely

            handle_response(ErrKind::THREAD_RUN_CREATION_ERROR) do
              response = client.runs.create(thread_id:,
                                            parameters: {assistant_id:,
                                                         stream:,
                                                         additional_instructions:})

              streaming ? lines : Structs::Run.new(**response)
            end
          end
        end
      end
    end
  end
end
