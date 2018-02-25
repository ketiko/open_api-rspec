module OpenApi
  module RSpec
    module Matchers
      module OpenApi
        ::RSpec::Matchers.define :match_openapi_response_schema do |schema|
          match do |response|
            ::OpenApi::SchemaValidator.validate_schema!(
              SwaggerSchema.to_h,
              response.is_a?(Hash) ? response : ::JSON.parse(response.body),
              fragment: "#/definitions/#{schema}"
            )
          end
        end

        ::RSpec::Matchers.define :be_valid_openapi_schema do
          match do |string|
            json = ::JSON.parse(string)
            ::OpenApi::SchemaValidator.validate!(json)
          end
        end
      end
    end
  end
end
