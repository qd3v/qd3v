module Qd3v
  module OpenAI
    module Structs
      class UserMessage < Message

        ROLE = "user"

        def role = ROLE
      end
    end
  end
end
