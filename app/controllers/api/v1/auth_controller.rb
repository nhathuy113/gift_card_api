module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate!, only: [:login]

      def login
        user = User.authenticate_by(email: login_params[:email], password: login_params[:password])
        unless user&.active?
          record_failed_login(user)
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

      private

      def login_params
        params.permit(:email, :password)
      end

      def render_invalid_credentials
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end

      def record_failed_login(authenticated)
        actor = authenticated || User.find_by(email: login_params[:email])
        if actor
          Current.set(user: actor) do
            AuditLog.record(action: "login.failed", outcome: :refused, record: actor)
          end
        else
          AuditLog.record(action: "login.failed", outcome: :refused, metadata: { email_digest: email_digest })
        end
      end

      def email_digest
        normalized = login_params[:email].to_s.strip.downcase
        OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, normalized)
      end
    end
  end
end
