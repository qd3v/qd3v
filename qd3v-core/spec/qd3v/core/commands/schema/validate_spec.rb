module Qd3v
  module Core
    module Commands
      module Schema
        RSpec.describe Validate do
          include_context :dry_result

          let(:result) { subject.call(schema:, data:) }

          let(:schema) do
            Dry::Schema.JSON do
              required(:email).filled(:string)
            end
          end

          let(:data) { {email: 'email@example.com'} }

          describe 'success' do
            example 'return context' do
              expect(result).to be_success
              expect(success).to eq(data)
            end
          end

          describe 'failure' do
            let(:data) { {email: ''} }

            example 'return raised error' do
              expect(result).to be_failure
              expect(error).to be_a(Err)
              expect(err_kind).to eq(ErrKind::SCHEMA_VALIDATION_FAILED)
              expect(err_errors).to eq(email: ["must be filled"])
            end
          end
        end
      end
    end
  end
end
