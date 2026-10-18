Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"

      namespace :admin do
        resources :clients, only: [:create]
        resources :brands, except: :destroy do
          patch :state, on: :member
          resources :products, except: :show, shallow: true do
            patch :state, on: :member
          end
        end
      end
    end
  end
end
