module Api
  module V1
    module Admin
      class ClientsController < BaseController
        def create
          client = ::Client.new(client_params)
          return render json: client.errors, status: :unprocessable_entity unless client.save

          render json: ClientSerializer.new(client), status: :created
        end

        def state
          client = ::Client.find(params[:id])
          return render json: client.errors, status: :unprocessable_entity unless client.update(state: params[:state])

          render json: ClientSerializer.new(client)
        rescue ArgumentError
          render json: { error: "Invalid state" }, status: :unprocessable_entity
        end

        private

        def client_params
          params.permit(:email, :password, :payout_rate)
        end
      end
    end
  end
end
