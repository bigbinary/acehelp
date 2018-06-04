# frozen_string_literal: true

# enable cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*\.(heroku|acehelp)\.com'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end
