module Api
  module V1
    module Client
      class ProductsController < BaseController
        def index
          products = current_client.accessible_products
                                   .includes(:brand)
                                   .by_brand(params[:brand_id])
                                   .search_by_name(params[:q])
                                   .order(:name)

          render json: products
        end
      end
    end
  end
end
