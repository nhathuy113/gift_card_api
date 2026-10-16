module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate!, only: [:login]

      def login
        user = User.authenticate_by(email: login_params[:email], password: login_params[:password])

        if user&.active?
          Audit.user = user
          Audit.record(action: "login.success", record: user)
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
        else
          Audit.record(action: "login.failed", outcome: :refused, metadata: { email: login_params[:email] })
          render_invalid_credentials
        end
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