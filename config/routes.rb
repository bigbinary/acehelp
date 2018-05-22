Rails.application.routes.draw do
  get '/', to: 'application#index'

  get "/getting-started", to: "application#getting_started"
  get "/integrations", to: "application#integrations"
  get "/pricing", to: "application#pricing"

end
