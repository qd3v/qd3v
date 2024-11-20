module Qd3v
  module OpenAI
    module Structs
      class Message < Dry::Struct
        # @!attribute [r] id
        #   @return [String] the message id.
        attribute :id, Types::Strict::String.optional.default(nil)

        # @!attribute [r] created_at
        #   @return [Integer] the timestamp when the message was created.
        attribute :created_at, Types::Strict::Integer.optional.default(nil)

        # @!attribute [r] assistant_id
        #   @return [String] the assistant's id.
        attribute :assistant_id, Types::Strict::String.optional.default(nil)

        # @!attribute [r] thread_id
        #   @return [String] the thread id.
        attribute :thread_id, Types::Strict::String

        # @!attribute [r] run_id
        #   @return [String] the run id.
        attribute :run_id, Types::Strict::String.optional.default(nil)

        # @!attribute [r] role
        #   @return [String] the role.
        attribute :role, Types::Strict::String.default("user".freeze)

        # @!attribute [r] content
        #   @return [Array<Content>] the content as an array of Content objects.
        attribute :content, Types::Array.of(Types::Strict::Hash)

        # @!attribute [r] attachments
        #   @return [Array] any attachments (here initialized as an empty array by default).
        attribute :attachments, Types::Array.default([].freeze)

        # @!attribute [r] metadata
        #   @return [Hash] the metadata for the message.
        attribute :metadata, Types::Strict::Hash.default({}.freeze)

        #
        # USELESS
        #

        # @!attribute [r] object
        #   @return [String] the object type.
        # attribute :object, Types::Strict::String.default("thread.message")

        # NOTE: id is set in path segment
        # WARN: we can only change metadata
        def to_update_payload
          to_hash.slice(:metadata)
        end

        def to_create_payload
          to_hash.except(:id, :created_at) # , :assistant_id
        end
      end
    end
  end
end
