module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate!, only: [:login]

      def login
        user = User.authenticate_by(email: login_params[:email], password: login_params[:password])
        unless user&.active?
          AuditLog.record(action: "login.failed", outcome: :refused, metadata: { email: login_params[:email] })
          return render_invalid_credentials
        end

        Current.user = user
        AuditLog.record(action: "login.success", record: user)
        token = JwtService.encode(user)

        render json: {
          token: token,
          user: {
            id: user.id,
            email: user.email,
            role: user.role,
            state: user.state,
            payout_rate: user.payout_rate&.to_f
          }
        }, status: :ok
      end

      def logout
        token = request.authorization.to_s[/\ABearer (.+)\z/, 1]
        payload = JwtService.decode(token)
        RevokedToken.create!(jti: payload.fetch(:jti), expires_at: Time.zone.at(payload.fetch(:exp)))
        head :no_content
      end

      private

      def login_params
        params.permit(:email, :password)
      end

      def render_invalid_credentials
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end
  end
end
