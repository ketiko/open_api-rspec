# frozen_string_literal: true

require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter /spec.rb$/
  end
  SimpleCov.at_exit do
    if ENV['CI']
      min = 50
      actual = SimpleCov.result.covered_percent
      system("lois simplecov -c travis -g $GITHUB_CREDENTIALS -m #{min} -a #{actual}")
    end
    SimpleCov.result.format!
  end
end
require 'open_api/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
