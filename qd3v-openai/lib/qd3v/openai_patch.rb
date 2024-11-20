# WARN: This patch expects openai gem already loaded (use provider)
# WARN: This is proof-of-concept before making proposal
module OpenAI
  module HTTP

    # $stderr.puts "Patching #{self}"

    private

    unless private_method_defined?(:to_json_stream)
      abort(<<~MSG.squish!)
        Unable to patch #{self}: method #to_json_stream not found.
        Probably openai gem not loaded, or method's visibility changed.
      MSG
    end

    # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
    # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could
    # be a data object or an error object as described in the OpenAI API documentation.
    #
    # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
    # @return [Proc] An outer proc that iterates over a raw stream, converting it to JSON.
    def to_json_stream(user_proc:)
      # $stderr.puts "Using patched #to_json_stream"
      parser = EventStreamParser::Parser.new

      proc do |chunk, bytesize, env|
        if env && env.status != 200
          raise_error = Faraday::Response::RaiseError.new
          raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
        end

        parser.feed(chunk) do |event, data, _event_id, _reconnection_time|
          break if data == "[DONE]"

          user_proc.call(event:, data: JSON.parse(data), bytesize:)
        end
      end
    end
  end
end
