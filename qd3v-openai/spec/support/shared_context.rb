RSpec.shared_context :shared do
  # MONAD SHORTCUTS

  let(:success) { result.success }
  let(:failure) { result.failure }

  # REQUEST

  let(:access_token) { ENV![:QD3V_OPENAI_TOKEN] }
  let(:organization_id) { ENV![:QD3V_OPENAI_ORG_ID] }

  let(:auth_headers) do
    {'Authorization'       => "Bearer #{access_token}",
     "Openai-Organization" => organization_id}
  end

  let(:headers) { {headers: auth_headers} }

  # RESPONSE

  let(:response_headers) do
    {"Content-Type" => "application/json"}
  end

  let(:status) { 200 }

  let(:to_return) do
    # WARN: webmock requires body to be string
    #       (rationale: https://github.com/bblimke/webmock/issues/449)
    {status:, body: response_body.to_json, headers: response_headers}
  end
end
