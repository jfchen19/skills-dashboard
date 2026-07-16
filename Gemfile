# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "erubi", "~> 1.13"
gem "kramdown", "~> 2.4"
gem "puma", ">= 6"
gem "rackup", "~> 2.2"
gem "sinatra", "~> 4.2"

group :development, :test do
  gem "bundler-audit", "~> 0.9", require: false
  gem "rack-test", "~> 2.1"
  gem "rspec", "~> 3.13"
  gem "rubocop", "~> 1.86", require: false
  gem "rubocop-rspec", "~> 3.8", require: false
end
