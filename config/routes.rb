Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"

      namespace :admin do
        resources :clients, only: [:create] do
          resource :client_accessible_products, only: %i[show update]
        end
        resources :brands, except: :destroy do
          patch :state, on: :member
          resources :products, except: :show, shallow: true do
            patch :state, on: :member
          end
        end
      end

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
