# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in unique_attributes.gemspec
gemspec

group :development do
  gem "codecov"
  gem "database_cleaner"
  gem "panolint-ruby", github: "panorama-ed/panolint-ruby", branch: "main"
  gem "pg"
  gem "rspec"
  gem "rspec-mocks"
  gem "sqlite3"
end
