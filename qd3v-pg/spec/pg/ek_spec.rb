module Qd3v
  module PG
    RSpec.describe EK do
      describe 'success' do
        let(:subject) do
          described_class[:unique_violation]
        end

        example 'return context' do
          expect(subject).to be_a(EK)
          expect(subject.inspect).to eq('qd3v.pg.err_kind.unique_violation')
        end
      end
    end
  end
end
