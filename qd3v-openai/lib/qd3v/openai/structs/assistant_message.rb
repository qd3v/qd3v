module Qd3v
  module OpenAI
    module Structs
      class AssistantMessage < Message
        ROLE = "assistant"

        def initialize(**attributes)
          super(attributes.update(role: ROLE))
        end

        def role=(role)
          raise ArgumentError, "role must be '#{ROLE}'" unless role == ROLE
          @attributes[:role] = role
        end
      end
    end
  end
end
