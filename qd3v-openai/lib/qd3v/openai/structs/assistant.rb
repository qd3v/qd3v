module Qd3v
  module OpenAI
    module Structs
      # This one is used to represent OAI Assistant structure
      # NOTE: [r] - read-only
      # NOTE: id and created_at are optional for Create action
      class Assistant < Dry::Struct
        # @!attribute [r] id
        #   @return [String] the assistant id.
        attribute :id, Types::Strict::String.optional.default(nil)

        # @!attribute [r] created_at
        #   @return [Integer] the timestamp when the assistant was created
        attribute :created_at, Types::Strict::Integer.optional.default(nil)

        # @!attribute [r] name
        #   @return [String] the name of the assistant
        attribute :name, Types::Strict::String

        # @!attribute [r] model
        #   @return [String] the model of the assistant
        attribute :model, Types::Strict::String

        # @!attribute [r] instructions
        #   @return [String] the instructions for the assistant
        attribute :instructions, Types::Strict::String.optional

        # @!attribute [r] metadata
        #   @return [Hash] the metadata for the assistant
        attribute :metadata, Types::Strict::Hash.default({}.freeze)

        # @!attribute [r] top_p
        #   @return [Float] the top_p attribute
        attribute :top_p, Types::Strict::Float.optional.default(0.5)

        # @!attribute [r] temperature
        #   @return [Float] the temperature of the assistant
        attribute :temperature, Types::Strict::Float.optional.default(1.0)

        # @!attribute [r] response_format
        #   @return [String] the response format of the assistant
        #   @return [Hash] the response format of the assistant
        attribute :response_format, Types::Strict::String | Types::Strict::Hash

        #
        # NOT USING
        #

        # @!attribute [r] description
        #   @return [String] the description of the assistant
        # attribute :description, Types::Strict::String.optional.default(nil)

        # @!attribute [r] tools
        #   @return [Array] the tools associated with the assistant
        # attribute :tools, Types::Strict::Array.default([].freeze)

        # @!attribute [r] tool_resources
        #   @return [Hash] the tool resources for the assistant
        # attribute :tool_resources, Types::Strict::Hash.default({}.freeze)

        # NOTE: This one is really useless, and even make things harder
        # @!attribute [r] object
        #   @return [String] the object type
        # attribute :object, Types::Strict::String.default("assistant")

        # NOTE: id is set in path segment
        def to_update_payload
          to_h.except(:id, :created_at, :description)
        end

        def to_create_payload
          to_update_payload
        end
      end
    end
  end
end
