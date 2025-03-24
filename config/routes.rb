Rails.application.routes.draw do
  root "images#new"
  resources :images, only: [:new, :create, :show]

  get "up" => "rails/health#show", as: :rails_health_check
end
