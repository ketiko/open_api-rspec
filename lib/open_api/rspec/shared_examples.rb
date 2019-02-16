# frozen_string_literal: true

module OpenApi
  module RSpec
    module SharedExamples
      ::RSpec.shared_examples_for :an_openapi_endpoint do
        let(:schema_hash) { ::JSON.parse(open_api_json) }
        let(:schema_parser) { OpenApi::RSpec::SchemaParser.new(schema_hash, request, response) }

        it 'matches the swagger.json for the request' do
          expect(schema_parser.schema_for_url).not_to(
            be_nil,
            'url not documented in swagger.json'
          )
          expect(schema_parser.schema_for_url_and_request_method).not_to(
            be_nil,
            'http method for url not documented'
          )
          schema_parser.openapi_required_query_string_params.each do |openapi_param|
            expect(schema_parser.request_params).to(
              include(openapi_param),
              'missing required request query parameters'
            )
          end
          schema_parser.openapi_required_path_params.each do |openapi_param|
            expect(schema_parser.request_path_params).to(
              include(openapi_param),
              'missing required request path parameters'
            )
          end
          schema_parser.openapi_required_form_data_params.each do |openapi_param|
            expect(schema_parser.request_params).to(
              include(openapi_param),
              'missing required request form data parameters'
            )
          end
          schema_parser.request_path_params.each do |request_param|
            expect(schema_parser.openapi_path_params).to(
              include(request_param),
              "#{request_param} is an undocumented request path parameter"
            )
          end
          schema_parser.request_params.each do |request_param|
            expect(schema_parser.openapi_request_params).to(
              include(request_param),
              "#{request_param} is an undocumented request parameter"
            )
          end
          expect(schema_parser.schema_for_url_and_request_method_and_response_status).not_to(
            be_nil,
            'http response status not documented'
          )
          response_schema = schema_parser.schema_for_url_and_request_method_and_response_status
          results = if response_schema['schema']
                      ::OpenApi::SchemaValidator.validate_schema!(
                        schema_hash,
                        ::JSON.parse(response.body),
                        fragment: response_schema['schema']['$ref']
                      )
                    else
                      response_schema
                    end

          expect(results).to be_truthy, 'response does not match documented schema'
        end
      end
    end
  end
end
