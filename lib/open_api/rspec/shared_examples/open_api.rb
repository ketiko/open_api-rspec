# frozen_string_literal: true

module OpenApi
  module RSpec
    module SharedExamples
      ::RSpec.shared_examples_for :an_openapi_endpoint do
        let(:schema_hash) { ::JSON.parse(open_api_json) }
        let(:schema_parser) { SchemaParser.new(schema_hash, request, response) }

        it 'has openapi documentation for url' do
          expect(schema_parser.schema_for_url).not_to be_nil
        end

        it 'matches an allowed http request method' do
          expect(schema_parser.schema_for_url_and_request_method).not_to be_nil
        end

        it 'has all required request query parameters' do
          schema_parser.openapi_required_query_string_params.each do |openapi_param|
            expect(schema_parser.request_params).to include(openapi_param)
          end
        end

        it 'has all required request path parameters' do
          schema_parser.openapi_required_path_params.each do |openapi_param|
            expect(schema_parser.request_path_params).to include(openapi_param)
          end
        end

        it 'has all required request form data parameters' do
          schema_parser.openapi_required_form_data_params.each do |openapi_param|
            expect(schema_parser.request_params).to include(openapi_param)
          end
        end

        it 'does not allow undocumented request path parameters' do
          schema_parser.request_path_params.each do |request_param|
            expect(schema_parser.openapi_path_params).to include(request_param)
          end
        end

        it 'does not allow undocumented request parameters' do
          schema_parser.request_params.each do |request_param|
            expect(schema_parser.openapi_request_params).to include(request_param)
          end
        end

        it 'matches an allowed http response status' do
          expect(schema_parser.schema_for_url_and_request_method_and_response_status).not_to be_nil
        end
        it 'matches the response schema' do
          response_schema = schema_parser.schema_for_url_and_request_method_and_response_status
          results = if response_schema[:schema]
                      ::OpenApi::SchemaValidator.validate_schema!(
                        schema_hash,
                        ::JSON.parse(response.body),
                        fragment: response_schema[:schema][:$ref]
                      )
                    else
                      response_schema
                    end

          expect(results).to be_truthy
        end
      end
    end
  end
end
