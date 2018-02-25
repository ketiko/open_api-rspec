# OpenApi::RSpec [![Build Status](https://travis-ci.org/ketiko/open_api-rspec.svg?branch=master)](https://travis-ci.org/ketiko/open_api-rspec)

RSpec matchers and shared examples for OpenApi

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'open_api-rspec'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install open_api-rspec

## Usage

Add a file with the following:

```ruby
#file: spec/support/openapi_schema.rb

RSpec.shared_context "Shared OpenAPI JSON" do
  let(:open_api_json) { '{my open api json schema'} }
end

RSpec.configure do |rspec|
  rspec.include_context "Shared OpenAPI JSON", type: :request
  rspec.include_context "Shared OpenAPI JSON", type: :controller
end
```

Test if your swagger.json endpoint is a valid schema.

```ruby
require 'rails_helper'

RSpec.describe SwaggerController, type: :request do
  describe '#swagger' do
    before do
      get '/swagger.json'
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.body).to be_valid_openapi_schema }
  end
end
```

Test that a response body matches a specific OpenApi Schema.
```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :request do
  describe '#show' do
    before do
      get '/users/1'
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to match_openapi_response_schema :User }
  end
end
```
Test that a request spec  matches an OpenApi Schema.
This will check body, path, query, form data params.
It will also fail if any unknown params are passed.
It checks that there is a documented response code and verifies its response schema
```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :request do
  describe '#show' do
    before do
      get '/users/1'
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to match_openapi_response_schema :User }
    it_behaves_like :an_openapi_endpoint
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/open_api-rspec.
