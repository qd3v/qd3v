module Qd3v
  module OpenAI
    module Threads
      module Commands
        RSpec.describe Create do
          include_context :dry_result

          describe 'success' do
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

          describe 'failure' do
          end
        end
      end
    end
  end
end
