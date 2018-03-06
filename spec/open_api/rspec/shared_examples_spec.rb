# frozen_string_literal: true

require 'spec_helper'
require 'action_dispatch'

RSpec.describe OpenApi::RSpec::SharedExamples do
  describe 'an_openapi_endpoint' do
    let(:open_api_json) { File.read('./spec/fixtures/petstore.json') }
    let(:valid_response) do
      Rack::MockResponse.new(200, {}, JSON.generate([id: 1, name: 'Sam']))
    end

    context 'when valid' do
      let(:request) do
        ActionDispatch::Request.new(
          Rack::MockRequest.env_for('/v1/pets', 'REQUEST_METHOD' => 'GET')
        )
      end
      let(:response) { valid_response }

      it_behaves_like :an_openapi_endpoint
    end

    context 'when invalid response body' do
      let(:request) do
        ActionDispatch::Request.new(
          Rack::MockRequest.env_for('/v1/pets', 'REQUEST_METHOD' => 'GET')
        )
      end
      let(:response) do
        Rack::MockResponse.new(200, {}, JSON.generate(invalid: :response))
      end

      it 'raises an error' do
        expect do
          it_behaves_like :an_openapi_endpoint
        end.to raise_error StandardError
      end
    end

    context 'when invalid method' do
      let(:request) do
        ActionDispatch::Request.new(
          Rack::MockRequest.env_for('/v1/pets', 'REQUEST_METHOD' => 'PUT')
        )
      end
      let(:response) { valid_response }

      it 'raises an error' do
        expect do
          it_behaves_like :an_openapi_endpoint
        end.to raise_error StandardError
      end
    end

    context 'when invalid query params' do
      let(:request) do
        ActionDispatch::Request.new(
          Rack::MockRequest.env_for('/v1/pets?invalid=true', 'REQUEST_METHOD' => 'PUT')
        )
      end
      let(:response) { valid_response }

      it 'raises an error' do
        expect do
          it_behaves_like :an_openapi_endpoint
        end.to raise_error StandardError
      end
    end
  end
end
