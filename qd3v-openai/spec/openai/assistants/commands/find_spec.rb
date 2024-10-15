module Qd3v
  module OpenAI
    module Assistants
      module Commands
        RSpec.describe Find do
          include_context :commands

          let(:id) { "aid" }
          let(:result) { subject.call(id:) }

          let(:response_body) do
            {id:,
             object:          "assistant",
             created_at:      1698984975,
             name:            "Math Tutor",
             description:     nil,
             model:           "gpt-4o",
             instructions:    "You are a personal math tutor",
             tools:           [{type: "code_interpreter"}],
             metadata:        {},
             top_p:           1.0,
             temperature:     1.0,
             response_format: "auto"}
          end

          let!(:request_stub) do
            stub_request(:get, "https://api.openai.com/v1/assistants/#{id}")
              .with(**headers).to_return(**to_return)
          end

          example "ok" do
            expect(result).to be_success
            expect(success).to be_a(Structs::Assistant)
            expect(success.model).to eq("gpt-4o")
          end
        end
      end
    end
  end
end
