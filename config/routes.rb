Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"

      namespace :admin do
        resources :clients, only: [:create]
      end
    end
  end
end
