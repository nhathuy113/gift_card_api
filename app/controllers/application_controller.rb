class ApplicationController < ActionController::API
  include Authenticatable
  include Authorizable

  prepend_before_action do
    Audit.user = nil
    Audit.ip = request.remote_ip
    Audit.user_agent = request.user_agent
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end
end