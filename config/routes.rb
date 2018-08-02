# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  post "/graphql", to: "graphql#execute"

  get "/pages/aceinvoice/getting_started", to: "home#getting_started"
  get "/pages/aceinvoice/integrations", to: "home#integrations"
  get "/pages/aceinvoice/pricing", to: "home#pricing"

  resources :organizations, only: [:show], param: :api_key do
    resources :articles
    resources :urls
    resources :categories
    resources :feedbacks, only: [:index]
    resources :tickets, only: [:index]
  end

  namespace :admin do
    resources :integrations, only: [:index]
    resources :dashboard, only: [:index]
  end

  if Rails.env.development?
    mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql"
  end
end
