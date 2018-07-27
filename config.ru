# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application


use Rack::Cors do
  allow do
    origins "*"
    resource '*', headers: :any, methods: :any
  end
end
