module Qd3v
  module Core
    RSpec.describe EK do
      describe 'success' do
        let(:subject) do
          described_class[:dummy_error]
        end

        example 'return context' do
          expect(subject).to be_a(EK)
          expect(subject.inspect).to eq('qd3v.core.err_kind.dummy_error')
        end
      end
    end
  end
end
