module Authorizable
  extend ActiveSupport::Concern

  private

  def require_admin!
    render json: { error: "Forbidden" }, status: :forbidden unless current_user.admin?
  end

  def require_client!
    render json: { error: "Forbidden" }, status: :forbidden unless current_user.client?
  end
end
