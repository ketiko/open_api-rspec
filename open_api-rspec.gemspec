
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "open_api/rspec/version"

Gem::Specification.new do |spec|
  spec.name          = "open_api-rspec"
  spec.version       = OpenApi::RSpec::VERSION
  spec.authors       = ["Ryan Hansen"]
  spec.email         = ["ketiko@gmail.com"]

  spec.summary       = %q{RSpec matchers and shared examples for OpenApi}
  spec.description   = %q{RSpec matchers and shared examples for OpenApi}
  spec.homepage      = "https://github.com/ketiko/open_api-rspec"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'lois'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'actionpack'

  spec.add_dependency 'rspec'
  spec.add_dependency 'open_api-schema_validator'
  spec.add_dependency 'activesupport'
end
