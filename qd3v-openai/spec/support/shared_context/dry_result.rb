RSpec.shared_context :dry_result do
  # This one is usually overridden by the spec
  let(:result) { subject.call }
  let(:success) { result.success }
  let(:error) { result.failure }
  let(:err_kind) { error.err_kind }
  let(:err_ctx) { error.context }
end
