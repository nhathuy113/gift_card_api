class ApplicationController < ActionController::API
  include Authenticatable
  include Authorizable

  before_action do
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end
end
