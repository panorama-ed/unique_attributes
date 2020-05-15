# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in unique_attributes.gemspec
gemspec

group :development do
  gem "panolint", github: "panorama-ed/panolint"
  if ENV["CI"] == "true" && ENV["ACTIVERECORD_VERSION"]
    gem "activerecord", ENV["ACTIVERECORD_VERSION"]
  end
end
