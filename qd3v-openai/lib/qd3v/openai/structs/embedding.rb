module Qd3v
  module OpenAI
    module Structs
      # This one is used to represent OAI Embedding structure
      # NOTE: [r] - read-only
      # NOTE: There's no to_update|create_payload here, we only read from remote
      class Embedding < Dry::Struct
        # @!attribute [r] object
        #   @return [String] The object type, which is always "embedding".
        attribute :object, Types::Strict::String

        # REVIEW: this type of items check is a huge overhead I think
        # @!attribute [r] embedding
        #   @return [Array<Float>] The embedding vector, which is a list of floats.
        attribute :embedding, Types::Strict::Array.of(Types::Strict::Float)

        # @!attribute [r] index
        #   @return [Integer] The index of the embedding in the list of embeddings.
        attribute :index, Types::Strict::Integer
      end
    end
  end
end
