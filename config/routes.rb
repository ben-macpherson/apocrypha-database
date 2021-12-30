Rails.application.routes.draw do
  resources :manuscripts
  devise_for :users
  root to: "application#index"
end
