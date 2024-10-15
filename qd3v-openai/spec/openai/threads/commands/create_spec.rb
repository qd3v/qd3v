module Qd3v
  module OpenAI
    module Threads
      module Commands
        RSpec.describe Create do
          include_context :commands

          let!(:request_stub) do
            Testing::Threads.stub_create_success(id: 'test')
          end

          example "ok" do
            expect(result).to be_success
            expect(success).to be_a(Structs::Thread)
            expect(success.id).to eq("test")

            expect(request_stub).to have_been_requested
          end
        end
      end
    end
  end
end
