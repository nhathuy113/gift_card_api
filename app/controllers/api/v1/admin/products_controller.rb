module Api
  module V1
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: %i[update destroy state]

        def index
          render json: ProductSerializer.new(Brand.find(params[:brand_id]).products)
        end

        def create
          product = Brand.find(params[:brand_id]).products.new(product_params)
          return render json: product.errors, status: :unprocessable_entity unless product.save

          render json: ProductSerializer.new(product), status: :created
        end

        def update
          return render json: @product.errors, status: :unprocessable_entity unless @product.update(product_params)

          render json: ProductSerializer.new(@product)
        end

        def destroy
          return render json: @product.errors, status: :unprocessable_entity unless @product.destroy

          head :no_content
        end

        def state
          return render json: @product.errors, status: :unprocessable_entity unless @product.update(state: params[:state])

          render json: ProductSerializer.new(@product)
        rescue ArgumentError
          render json: { error: "Invalid state" }, status: :unprocessable_entity
        end

        private

        def set_product
          @product = Product.find(params[:id])
        end

        def product_params
          params.permit(:name, :price_value, custom_fields: %i[name value])
        end
      end
    end
  end
end
