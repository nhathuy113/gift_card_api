module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  private

  attr_reader :current_user

  def authenticate!
    @current_user = authenticate_token
    return render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user

    Current.user = @current_user
  end

  def authenticate_token
    token = request.authorization.to_s[/\ABearer (.+)\z/, 1]
    return nil if token.blank?

    payload = JwtService.decode(token)
    return nil if payload.blank?
    return nil if RevokedToken.exists?(jti: payload[:jti])

    user = User.find_by(id: payload[:user_id])
    user if user&.active?
  end
end
