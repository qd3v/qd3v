module Qd3v
  module OpenAI
    module Structs
      # This one is used to represent OAI Thread structure
      # API: https://platform.openai.com/docs/api-reference/runs/object
      class Run < Dry::Struct
        # @!attribute [r] id
        #   @return [String] the run id.
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

        # The status of the run, which can be either
        # queued, in_progress, requires_action, cancelling, cancelled, failed, completed, incomplete, or expired

        # @!attribute [r] thread_id
        #   @return [String] the thread id.
        attribute :status, Types::Strict::String.optional.default(nil)

        # @!attribute [r] metadata
        #   @return [Hash] the metadata for the message.
        attribute :usage, Types::Strict::Hash.optional.default(nil)

        #
        # USELESS: lots of them
        #

        #
        # PAYLOAD (NOT USING YET)
        #

        # We need only assistant_id here + we want streaming
        def to_create_payload
          to_hash.slice(:assistant_id).update(stream: stream_proc)
        end

        # COPIED TO COMMANDS:CREATE
        def stream_proc
          lines = ''
          proc do |chunk, _bytesize|
            if chunk['object'] == 'thread.message.delta'
              lines << chunk.dig('delta', 'content', 0, 'text', 'value')
            end
          end
        end
      end
    end
  end
end
