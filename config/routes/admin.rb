namespace :admin do
  resources :dashboard, only: [:index]
  resources :articles
  resources :urls
end
