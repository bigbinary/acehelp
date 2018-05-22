Rails.application.routes.draw do
  get '/', to: 'application#index'

  get "/getting-started", to: "application#getting_started"
  get "/integrations", to: "application#integrations"
  get "/pricing", to: "application#pricing"

  namespace :api, defaults: {format: 'json'} do
    namespace :v1, module: 'v1' do
      get "/all" => "library#all"
    end
  end

end
