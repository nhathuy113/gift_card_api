Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"

      if Rails.env.test?
        namespace :admin do
          get "test", to: "test_endpoints#index"
        end
        namespace :client do
          get "test", to: "test_endpoints#index"
        end
      end
    end
  end
end
