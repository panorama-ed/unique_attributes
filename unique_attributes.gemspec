# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "unique_attributes/version"

Gem::Specification.new do |spec|
  spec.name          = "unique_attributes"
  spec.version       = UniqueAttributes::VERSION
  spec.authors       = ["Jacob Evelyn"]
  spec.email         = ["jevelyn@panoramaed.com"]
  spec.summary       = "Auto-assign unique attributes for ActiveRecord objects."
  spec.description   = "Easily set ActiveRecord attributes to auto-generate "\
    "as unique values from a given proc."
  spec.homepage      = "https://www.github.com/panorama-ed/unique_attributes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
  spec.add_development_dependency "database_cleaner", "~> 1.4"
  spec.add_development_dependency "overcommit", "~> 0.21"
  spec.add_development_dependency "pg", "~> 1.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rspec-mocks", "~> 3.1"
  spec.add_development_dependency "rubocop", "~> 0.49"
  spec.add_development_dependency "sqlite3", "~> 1.3"
end
