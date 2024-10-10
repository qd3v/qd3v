module Qd3v
  module OpenAI
    module Messages
      module Commands
        class Create < Command
          # Retrieve an assistant from the client and return it as an instance of the Assistant entity.
          # API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#threads-and-messages
          # @param [String] thread_id The ID of the assistant to retrieve.
          # @param [String] prompt
          # @return [Dry::Monads::Result::Success<Structs::Message>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(thread_id:, prompt:)
            T.assert_type!(thread_id, String)
            T.assert_type!(prompt, String)

            logger.info("Creating new message", thread_id:, prompt:)

            handle_response(err_kind: ErrKind::THREAD_MESSAGE_CREATION_ERROR) do
              client.messages.create(thread_id:,
                                     parameters: {
                                       role: 'user', # Required for manually created messages
                                       content: prompt})
            end.fmap { Structs::Message.new(**_1) }
          end
        end
      end
    end
  end
end
