module Qd3v
  module Testing
    module Core
      module RSpec
        module Logger
          def logger
            @logger ||= SemanticLogger['RSPEC']
          end
        end
      end
    end
  end
end
