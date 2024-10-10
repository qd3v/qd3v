module Qd3v
  module OpenAI
    RSpec.describe EK do
      describe 'success' do
        let(:subject) do
          described_class[:embedding_creation_error]
        end

        example 'return context' do
          expect(subject).to be_a(EK)
          expect(subject.inspect).to eq('qd3v.openai.err_kind.embedding_creation_error')
        end
      end
    end
  end
end
