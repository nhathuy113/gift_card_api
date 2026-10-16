class ApplicationController < ActionController::API
  include Authenticatable
  include Authorizable

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end
end