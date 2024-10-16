module Qd3v
  module OpenAI
    module Threads
      module Commands
        RSpec.describe Find do
          include_context :dry_result

          let(:id) { 'test' }
          let(:result) { subject.call(id:) }

          describe 'success' do
            let!(:request_stub) do
              Testing::Threads.stub_find_success(id:)
            end

            example "ok" do
              expect(result).to be_success
              expect(success).to be_a(Structs::Thread)
              expect(success.id).to eq(id)

              expect(request_stub).to have_been_requested
            end
          end

          describe 'failure' do
            context 'not found' do
              let!(:request_stub) do
                Testing::Threads.stub_not_found(id:)
              end

              example "error" do
                expect(result).to be_failure
                expect(error).to be_an(Err)

                expect(err_kind).to eq(ErrKind::THREAD_NOT_FOUND)

                expect(request_stub).to have_been_requested
              end
            end
          end
        end
      end
    end
  end
end
