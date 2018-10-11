# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  devise_for :users

  get "/pages/aceinvoice/getting_started", to: "home#getting_started"
  get "/pages/aceinvoice/integrations", to: "home#integrations"
  get "/pages/aceinvoice/pricing", to: "home#pricing"

  namespace :graphql_execution do
    resource :dashboard, only: :create
    resource :widget, only: :create
  end

  scope module: 'admin' do
    resources :organizations, only: :new
  end

  resources :organizations, only: [:show], param: :api_key do
    resources :articles, only: [:index] do
      resources :attachments, module: :articles, only: [:create, :destroy]
    end
    get "*path", to: "admin/dashboard#index", constraints: -> (request) do
      !request.xhr? && request.format.html?
    end
  end

  if Rails.env.development?
    mount GraphqlPlayground::Rails::Engine, at: "/graphql/playground", graphql_path: "/graphql_execution/widget"
  end

  get "*path", to: "home#new", constraints: -> (request) do
    !request.xhr? && request.format.html?
  end
end
