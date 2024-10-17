module Qd3v
  module Core
    module Commands
      module JSON
        class Parse
          def call(json:, symbolize: true)
            # OJ docs: https://github.com/ohler55/oj/blob/develop/pages/Options.md
            # WARN: Oj naming: #load instead of #parse
            Try[Oj::ParseError] {
              Oj.load(json, symbol_keys: symbolize)
            }.to_result.or do |exception|
              Err[ErrKind::JSON_PARSING_ERROR,
                  binding:, exception:,
                  context: {json:, symbolize:}]
            end
          end
        end
      end
    end
  end
end
