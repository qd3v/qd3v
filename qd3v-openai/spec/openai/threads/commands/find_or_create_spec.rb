module Qd3v
  module OpenAI
    module Threads
      module Commands
        # We're not hitting network here, just correctness of commands
        RSpec.describe FindOrCreate do
          include_context :dry_result

          let(:id) { 'test' }

          let(:result) { described_class.new(**di).call(id:) }

          # Instance doubles checks correctness of args
          # Here we don't care if not mocked dep called: we can see that by result

          let(:cmd_find) { instance_double(Find, call: Success(:found)) }
          let(:cmd_find_f) { instance_double(Find, call: Failure(:not_found)) }

          let(:cmd_create) { instance_double(Create, call: Success(:created)) }
          let(:cmd_create_f) { instance_double(Create, call: Failure(:not_created)) }

          describe 'success' do
            context 'found' do
              let(:di) { {cmd_find:} }

              example do
                expect(result).to be_success
                expect(success).to eq(:found)
              end
            end


            context 'not found->create' do
              let(:di) { {cmd_find: cmd_find_f, cmd_create: } }

              example do
                expect(result).to be_success
                expect(success).to eq(:created)
              end
            end
          end

          describe 'failure' do
            context 'not found->creation failed' do
              let(:di) { {cmd_find: cmd_find_f, cmd_create: cmd_create_f } }

              example do
                expect(result).to be_failure
                expect(error).to eq(:not_created)
              end
            end
          end
        end
      end
    end
  end
end
