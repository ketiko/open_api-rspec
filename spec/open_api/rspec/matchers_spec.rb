require 'spec_helper'

RSpec.describe OpenApi::RSpec::Matchers do
  describe 'be_valid_openapi_schema' do
    context 'when valid' do
      subject(:valid_json) { File.read('./spec/fixtures/petstore.json') }

      it { is_expected.to be_valid_openapi_schema }
    end

    context 'when invalid' do
      subject(:invalid_json) { File.read('./spec/fixtures/invalid.json') }

      it 'raises an error' do
        expect {
          is_expected.not_to be_valid_openapi_schema
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'match_openapi_response_schema' do
      let(:open_api_json) { JSON.parse(File.read('./spec/fixtures/petstore.json')) }

    context 'when valid' do
      subject { pet_response }

      let(:pet_response) do
        {
          id: 1,
          name: 'Sam'
        }
      end

      it { is_expected.to match_openapi_response_schema :Pet }
    end

    context 'when invalid' do
      subject { pet_response }

      let(:pet_response) do
        {
          id: 1
        }
      end

      it 'raises an error' do
        expect {
          is_expected.not_to match_openapi_response_schema :Pet
        }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
