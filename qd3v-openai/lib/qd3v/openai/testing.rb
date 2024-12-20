module Qd3v
  module OpenAI
    # WARN: webmock requires body to be string
    #       (rationale: https://github.com/bblimke/webmock/issues/449)
    #
    # WARN: webmock DOES NOT print expected body for stubs that didn't match (list of all defined)
    #
    # JSON RESPONSE
    #
    # Webmock has #to_return_json method, that
    # - sets "Content-Type" => "application/json" for us
    # - converts body to json unless is a string
    module Testing

      BASE_URL = "https://api.openai.com/v1"

      ACCESS_TOKEN    = ENV![:QD3V_OPENAI_TOKEN]
      ORGANIZATION_ID = ENV![:QD3V_OPENAI_ORG_ID]

      AUTH_HEADERS = {
        'Authorization'       => "Bearer #{ACCESS_TOKEN}",
        "Openai-Organization" => ORGANIZATION_ID
      }

      HEADERS = {
        headers: AUTH_HEADERS.merge(
          "Openai-Beta"  => "assistants=v2",
          "Content-Type" => "application/json"
        )
      }

      # RESPONSE

      RESPONSE_HEADERS = {}

      STATUS_OK           = 200
      STATUS_CREATED      = 201
      STATUS_ACCEPTED     = 202
      STATUS_NO_CONTENT   = 204

      STATUS_BAD_REQUEST  = 400
      STATUS_UNAUTHORIZED = 401
      STATUS_FORBIDDEN    = 403
      STATUS_NOT_FOUND    = 404

      # Yield only works for methods, call block the old way
      ENDPOINT = ->(method, *path, &block) {
        url = File.join(BASE_URL, *path)
        block.call(WebMock::API.stub_request(method, url))
      }

      # TODO: DRY after having whole bunch of stubs
      module Threads

        class << self

          def id = "thread_#{SecureRandom.alphanumeric(25)}"

          def stub_create_success(id: id)
            to_return = {status: STATUS_OK, body: thread_response(id:)}

            ENDPOINT.(:post, 'threads') do
              it.with(body: {}, **HEADERS).to_return_json(**to_return)
            end
          end

          def stub_create_bad_request(id: id)
            to_return = {status: STATUS_BAD_REQUEST}

            ENDPOINT.(:post, 'threads') do
              it.with(body: {}, **HEADERS).to_return_json(**to_return)
            end
          end

          def stub_find_success(id: id)
            to_return = {status: STATUS_OK, body: thread_response(id:)}

            ENDPOINT.(:get, 'threads', id) do
              it.with(body: {}, **HEADERS).to_return_json(**to_return)
            end
          end

          def stub_not_found(id: id)
            to_return = {status: STATUS_NOT_FOUND, body: not_found_response(id:)}

            ENDPOINT.(:get, 'threads', id) do
              it.with(body: {}, **HEADERS).to_return_json(**to_return)
            end
          end

          def thread_response(id: id)
            {
              id:,
              object:         "thread",
              created_at:     Time.current.to_i,
              metadata:       {},
              tool_resources: {}
            }
          end

          def not_found_response(id: id)
            {
              "error": {
                "message": "No thread found with id '#{id}'.",
                "type":    "invalid_request_error",
                "param":   nil,
                "code":    nil
              }
            }
          end
        end
      end
    end
  end
end
