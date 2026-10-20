Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "login", to: "auth#login"

      namespace :admin do
        resources :audit_logs, only: :index
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

      namespace :client do
        resources :products, only: :index
        resources :cards, only: :create do
          post :cancel, on: :collection
        end
      end
    end
  end
end
