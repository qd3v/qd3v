module Qd3v
  module Testing
    module Core
      # Useful to test DI/Containers configuration
      class Dummy
        def call
          puts "#{self.class.name} test call"
        end
      end
    end
  end
end
