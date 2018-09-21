# frozen_string_literal: true

# enable cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do


  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end


  allow do
    origins "*"
    resource "/api/*/all", headers: :any, methods: [:get, :post, :put, :delete, :options, :head]
  end

  allow do
    origins "*"
    resource "/api/*/article", headers: :any, methods: [:get, :post, :put, :delete, :options, :head]
  end

  allow do
    origins "*"
    resource "/api/*/article/*", headers: :any, methods: [:get, :post, :put, :delete, :options, :head]
  end

  allow do
    origins "*"
    resource "/api/*/articles/*", headers: :any, methods: [:get, :post, :put, :delete, :options, :head]
  end

  allow do
    origins "*"
    resource "/packs/*", headers: :any, methods: :get
  end

  allow do
    origins "*"
    resource "/graphql", headers: :any, methods: [:get, :post, :put, :delete, :options, :head]
  end
end
