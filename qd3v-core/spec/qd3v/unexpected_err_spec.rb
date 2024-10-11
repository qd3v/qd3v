module Qd3v
  # RATIONALE: I found it's useful in catch-all case's else condition
  RSpec.describe UnexpectedErr do
    describe 'success' do
      let(:context) { {a: 100} }
      example 'return context' do
        exception = begin
                      raise "Test cause"
        rescue StandardError => e
                      e
        end

        err = Err.new(Core::ErrKind::DUMMY_ERROR, binding:, exception:, context:)

        test = proc do
          case err
          in context: {a: 300}
            raise("Unexpected test behaviour")
          else
            raise UnexpectedErr.new(err)
          end
        end

        expect(&test).to raise_error(UnexpectedErr) do
          expect(it.message).to match(/Got Unexpected Err object: Err.+Dummy error used.+Test cause/i)
          expect(it.cause).to be_a(StandardError)
          expect(it.cause.message).to eq("Test cause")
        end
      end
    end
  end
end
