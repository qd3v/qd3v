module Qd3v
  module Core
    module Commands
      module Schema
        class Validate
          # WARN: Dry schema may mutate data, so always use the one returned in Success
          # @param schema [Dry::Schema]
          # @param data [Hash]
          # @return [Success<Hash>,Failure<Err>]
          def call(schema:, data:)
            T.assert_type!(schema, Dry::Schema::Processor) # base class for Params/JSON
            T.assert_type!(data, Hash)
            # To monad returns Result<Dry::Schema::Result>, which we turn back to hash
            schema.call(data)
                  .to_monad
                  .fmap { it.to_h }
                  .or { |result|
                    Err[ErrKind::SCHEMA_VALIDATION_FAILED,
                        binding:, context: {data: result.to_h}, errors: result.errors.to_h]
            }
          end
        end
      end
    end
  end
end
