module Qd3v
  module OpenAI
    module Embeddings
      module Commands
        class Create < Command
          DEFAULT_EMBEDDING_MODEL = "text-embedding-3-small"

          # GEM API: https://github.com/alexrudall/ruby-openai?tab=readme-ov-file#embeddings
          # API: https://platform.openai.com/docs/api-reference/embeddings/create
          # NOTE: Technically input can be array of tokens, but I have no idea why this ever need
          # @param text [String] input text to embed
          # @return [Dry::Monads::Result::Success<Qd3v::OpenAI::OAI::Structs::Embedding>, Dry::Monads::Result::Failure] The retrieved assistant wrapped in a Success. In case of an error, the method will return a Failure monad.
          def call(text:, model: DEFAULT_EMBEDDING_MODEL)
            T.assert_type!(text, String)

            handle_response(err_kind: ErrKind::EMBEDDING_CREATION_ERROR) do
              client.embeddings(parameters: {input: text, model:})
            end.fmap do
              embedding = it.fetch(:data).first
              Structs::Embedding.new(**embedding).tap do
                logger.debug("Got embedding from OpenAI", text:, size: it.embedding.size)
              end
            end
          end
        end
      end
    end
  end
end
