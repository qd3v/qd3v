module Qd3v
  module OpenAI
    module Structs
      # This one is used to represent OAI Assistant structure
      # Docs: https://platform.openai.com/docs/api-reference/assistants/object
      # NOTE: [r] - read-only
      class Assistant < Dry::Struct
        # @!attribute [r] id
        #   @return [String] the assistant id.
        attribute :id, Types::Strict::String.optional.default(nil)

        # @!attribute [r] model
        #   @return [String] the model of the assistant
        attribute :model, Types::Strict::String

        # TODO: The maximum length is 256,000 characters.
        # @!attribute [r] instructions
        #   @return [String] the instructions for the assistant
        attribute :instructions, Types::Strict::String.optional

        # WARN: Name may not be unique on OpenAI side
        # TODO: The maximum length is 256 characters.
        # @!attribute [r] name
        #   @return [String] the name of the assistant
        attribute :name, Types::Strict::String.optional

        # TODO: The maximum length is 512 characters.
        # WARN: There's a bug or docs mismatch: they claim to let null on update, but that's no true
        #   Replace with `nil` if fixed
        # @!attribute [r] description
        #   @return [String] the description of the assistant
        attribute :description, Types::Strict::String.optional.default(''.freeze)

        # @!attribute [r] metadata
        #   @return [Hash] the metadata for the assistant
        attribute :metadata, Types::Strict::Hash.default({}.freeze)

        # TODO: between 0.1 and 2.0 (default 1.0)
        # We generally recommend altering this or top_p but not both.
        # @!attribute [r] temperature
        #   @return [Float] the temperature of the assistant
        attribute :temperature, Types::Strict::Float.optional.default(1.0)

        # TODO: between 0.1 and 1.0 (default)
        # We generally recommend altering this or temperature but not both.
        # @!attribute [r] top_p
        #   @return [Float] the top_p attribute
        attribute :top_p, Types::Strict::Float.optional.default(1.0)

        # @!attribute [r] response_format
        #   @return [String] the response format of the assistant
        #   @return [Hash] the response format of the assistant
        attribute :response_format, Types::Strict::String | Types::Strict::Hash

        # TODO: between There can be a maximum of 128 tools per assistant.
        # @!attribute [r] tools
        #   @return [Array] the tools associated with the assistant
        attribute :tools, Types::Strict::Array.default([].freeze)

        # @!attribute [r] tool_resources
        #   @return [Hash] the tool resources for the assistant
        attribute :tool_resources, Types::Strict::Hash.default({}.freeze)

        # @!attribute [r] created_at
        #   @return [Integer] the timestamp when the assistant was created
        attribute :created_at, Types::Strict::Integer.optional.default(nil)

        # NOTE: This one is really useless, and even make things harder
        # @!attribute [r] object
        #   @return [String] the object type
        # attribute :object, Types::Strict::String.default("assistant")

        # NOTE: id is set in path segment
        def to_update_payload
          to_h.except(:id, :created_at)
        end

        def to_create_payload
          to_update_payload
        end
      end
    end
  end
end
