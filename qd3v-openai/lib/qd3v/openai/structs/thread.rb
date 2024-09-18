module Qd3v
  module OpenAI
    module Structs
      # This one is used to represent OAI Thread structure
      class Thread < Dry::Struct
        # Define attributes and their types here
        attribute :id,             Types::Strict::String
        attribute :object,         Types::Strict::String
        attribute :created_at,     Types::Strict::Integer
        attribute :metadata,       Types::Strict::Hash.default({}.freeze)
        attribute :tool_resources, Types::Strict::Hash.default({}.freeze)
      end
    end
  end
end
