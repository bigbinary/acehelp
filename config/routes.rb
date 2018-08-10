# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'users', controllers: {
    registrations: "registrations",
    sessions: "devise_sessions"
  }

  root to: "home#index"

  post "/graphql", to: "graphql#execute"

  get "/pages/aceinvoice/getting_started", to: "home#getting_started"
  get "/pages/aceinvoice/integrations", to: "home#integrations"
  get "/pages/aceinvoice/pricing", to: "home#pricing"

  scope module: 'admin' do
    resources :organizations, only: :new
  end

  resources :organizations, only: [:show], param: :api_key do
    resources :articles, only: :index
    get "*path", to: "admin/dashboard#index", constraints: -> (request) do
      !request.xhr? && request.format.html?
    end
  end

  if Rails.env.development?
    mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql"
  end

  get "*path", to: "home#new", constraints: -> (request) do
    !request.xhr? && request.format.html?
  end
end
