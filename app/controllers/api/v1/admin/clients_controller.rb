module Api
  module V1
    module Admin
      class ClientsController < BaseController
        def create
          client = ::Client.new(client_params)

          if client.save
            render json: {
              id: client.id,
              email: client.email,
              role: client.role,
              state: client.state,
              payout_rate: client.payout_rate.to_f
            }, status: :created
          else
            render json: client.errors, status: :unprocessable_entity
          end
        end

        private

        def client_params
          params.permit(:email, :password, :payout_rate)
        end
      end
    end
  end
end
