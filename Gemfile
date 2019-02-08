source "https://rubygems.org"

# Specify your gem's dependencies in unique_attributes.gemspec
gemspec

if ENV["TRAVIS"] == "true" && ENV["ACTIVERECORD_VERSION"]
  gem "activerecord", ENV["ACTIVERECORD_VERSION"]
end
