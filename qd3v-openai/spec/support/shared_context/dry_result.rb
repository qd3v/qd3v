RSpec.shared_context :dry_result do
  # This one is usually overridden by the spec
  let(:result) { subject.call }
  let(:success) { result.success }
  let(:error) { result.failure }
end
