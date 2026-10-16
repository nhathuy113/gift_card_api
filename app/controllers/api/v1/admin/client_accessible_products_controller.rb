module Api
  module V1
    module Admin
      class ClientAccessibleProductsController < BaseController
        before_action :set_client

        def show
          render json: ProductSerializer.new(@client.accessible_products)
        end

        def update
          @client.accessible_product_ids = client_accessible_product_params[:product_ids]

          render json: ProductSerializer.new(@client.accessible_products)
        end

        private

        def set_client
          @client = ::Client.find(params[:client_id])
        end

        def client_accessible_product_params
          params.permit(product_ids: [])
        end
      end
    end
  end
end
