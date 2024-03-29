# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
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
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "activesupport", ">= 4.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
