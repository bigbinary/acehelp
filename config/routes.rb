# frozen_string_literal: true

Rails.application.routes.draw do
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join('config', 'routes', "#{routes_name}.rb")))
  end

  draw :admin

  devise_for :users

  post "/graphql", to: "graphql#execute"

  get "/", to: "home#index"

  get "/getting-started", to: "home#getting_started"
  get "/integrations", to: "home#integrations"
  get "/pricing", to: "home#pricing"

  resources :article, except: [:show, :new]
  resources :url, except: [:show, :new]

  namespace :api, defaults: { format: "json" } do
    namespace :v1, module: "v1" do
      get "/all", to: "category#index"

      resources :article, only: [:show, :index]

      get "articles/search", to: "article#search"

      resource :contacts, only: :create
    end
  end

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :articles
    resources :urls
  end

  if Rails.env.development?
    mount GraphqlPlayground::Rails::Engine, at: '/graphql/playground', graphql_path: '/graphql'
  end
end
