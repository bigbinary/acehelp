# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.2.1"

# Use this gem for maintaining sessions
gem "devise", "~> 4.4.0"

# Use pg as the database for Active Record
gem "pg"

# Use Puma as the app server
gem "puma", "~> 3.11"

# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"

# slim as a templating language
gem "slim", "3.0.6"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker"

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "mini_racer", platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use ActiveStorage variant
# gem "mini_magick", "~> 4.8"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Making it easy to serialize models for client-side use
gem "active_model_serializers", "~> 0.10.7"

# To build graphql server
gem "graphql"
# To resolve N+1 query in Graphql
gem "graphql-preload"

# Intelligent search made easy with Rails and Elasticsearch
gem "searchkick"

# Cross-Origin Resource Sharing (CORS) for Rack compatible web applications
gem "rack-cors", require: "rack/cors"

# for background job processing
gem "delayed_job_active_record"

# Delayed Job extension for writing recurring jobs.
gem "delayed_job_recurring"

# for user_agent/device detection
gem 'browser'

# for error tracking
gem 'honeybadger', '~> 4.0'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  # For splitting tests across CircleCI containers
  gem "knapsack"
  # customizable MiniTest output formats
  gem "minitest-reporters", require: false
  # Minitest reporter plugin for CircleCI. Gerates JUnit xml reports from tests. https://github.com/circleci/minitest-ci
  gem "minitest-ci"
  gem "minitest", "5.10.3"
  gem "awesome_print", "1.8.0"
  gem "pry-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"

  # Patch-level verification for Bundler. https://github.com/rubysec/bundler-audit
  gem "bundler-audit", require: false
  # vulnerabity checker for Ruby itself. https://github.com/civisanalytics/ruby_audit
  gem "ruby_audit", require: false

  # A Ruby static code analyzer, based on the community Ruby style guide
  gem "rubocop", require: false

  #  For mountable GraphQL Playground endpoint
  gem "graphql_playground-rails", "~> 1.0"
end

group :test do
  gem "nokogiri", ">= 1.8.5"
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15", "< 4.0"
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem "chromedriver-helper"
  # A friendlier Ruby client for consuming GraphQL-based APIs.
  gem "graphlient", "~> 0.3.2"
  # SimpleCov is a code coverage analysis tool for Ruby
  gem "simplecov", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
