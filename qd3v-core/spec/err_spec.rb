module Qd3v
  module Core
    RSpec.describe Err do
      let(:err_kind) { ErrKind::DUMMY_ERROR }
      let(:context) { {a: 100} }
      let(:errors) { {base: %w[oops1]} }

      example "basics" do
        f = Err[err_kind, binding:, errors: nil, context:, http_status: 410]

        expect(f).to be_a(Failure)

        error = f.failure

        expect(error).to be_a(Err)
        expect(error.message).to match(/dummy error/i)
        expect(error.errors).to eq({}) # forced to be hash if nil (same for context)
        expect(error.context).to eq(a: 100)
        expect(error.err_kind).to eq(err_kind)
        expect(error.to_h).to include(context:)
        expect(error.to_public).to include(http_status:             410,
                                           http_status_description: 'Gone')
        expect(error.source).to eq(self.class.name)
        expect(error.file_path).to match(/err_spec\.rb\z/)
        expect(error.file_line).to match(/err_spec\.rb:\d+\z/)
      end

      example "with exception" do
        f = begin
          raise "Nope"
        rescue StandardError => e
          Err[err_kind, binding:, exception: e, errors:]
        end

        expect(f).to be_a(Failure)

        error = f.failure
        expect(error).to be_exceptional
        expect(error.errors).to match(errors)
        expect(error.exception_message).to eq("Nope")
        expect(error.exception_class).to eq(RuntimeError)
        expect(error.exception).to be_an_instance_of(RuntimeError)
        expect(error.file_path).to match(/err_spec\.rb\z/)
        expect(error.file_line).to match(/err_spec\.rb:\d+\z/)
      end

      # IMP: use rspec's yield helpers. yield_with_args(Err)
      # UPD: spec then become hard to understand, keeping simple
      example "yield self" do
        counter = 0
        err     = nil

        f = Err[err_kind, binding:, errors: nil, context:] do
          counter += 1
          err      = it
        end

        expect(f).to be_an_instance_of(Failure)
        expect(counter).to eq(1)
        expect(err).to be_an_instance_of(Err)
      end

      describe "ActiveModel-style errors" do
        example "ok" do
          f = nil

          expect {
            f = Err[err_kind, binding:, errors:,]
          }.not_to raise_error

          expect(f).to be_a(Failure)
          error = f.failure
          expect(error.errors).to eq(errors)
        end

        # TODO: This TypeError is not very informative
        context "invalid errors hash" do
          example "should raise if array" do
            errors = ["test"] # Not hash

            expect {
              Err[err_kind, binding:, errors:]
            }.to raise_error(TypeError)
          end

          example "should raise if hash but not array of strings as values" do
            pending("T.assert_type! ignored")
            errors = {base: 'oops'} # Should be array or strings

            expect {
              Err[err_kind, binding:, errors:]
            }.to raise_error(TypeError)
          end
        end
      end

      example "Enumerable" do
        expect { Err[err_kind, binding:, context:, errors:].failure.each(&it) }.to yield_control
      end

      # NOTE: Try's failure scenarios contain only exception, nothing more
      # API docs: https://dry-rb.org/gems/dry-monads/1.6/try/
      describe "Try integration" do
        example "to failure" do
          f = Try { raise "Oops" }
              .to_result
              .or { |exception| Err[err_kind, binding:, exception:, context:, errors:] }

          expect(f).to be_a(Failure)
        end

        example "keep success" do
          f = Try { 100 }
              .to_result
              .or { |exception| Err[err_kind, binding:, exception:] }

          expect(f).to eq(Success(100))
        end
      end

      describe "pattern matching" do
        # Currently I like this syntax of PM more, though more wordy
        example "hash destruct" do
          failure = Err[err_kind, binding:, context:, errors:]

          case failure
          in Failure(err_kind: ErrKind::DUMMY_ERROR, context: {a:}, errors:)
            expect(a).to eq(100)
            expect(errors).to eq({base: ['oops1']})
          else
            raise("Didn't match")
          end
        end

        # @note experimental API. Need to choose one
        example "array destruct" do
          failure = Err.new(err_kind, binding:, context:, errors:).to_array_failure

          case failure
          in Failure[ek, {context: {a:}, errors:}]
            expect(ek).to eq(err_kind)
            expect(a).to eq(100)
            expect(errors).to eq({base: ['oops1']})
          else
            raise("Didn't match")
          end
        end
      end

      describe "subscribers" do
        example "call subscribers" do
          # By default logs, removing
          Err.clear_subscribers

          call_result = false
          listener    = ->(err) { call_result = err }

          Err.add_subscribers(listener)

          f = Err[err_kind, binding:]

          expect(call_result).to eq(f.failure)
        end

        # TODO: Test this, spy on logger or something
        example "automated logging" do
          pending "Test this, spy on logger or something"
          Err[err_kind, binding:]

          expect(true).to(eq(false))
        end
      end
    end
  end
end
