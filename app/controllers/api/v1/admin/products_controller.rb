module Api
  module V1
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: %i[update destroy state]

        def index
          render json: Brand.find(params[:brand_id]).products
        end

        def create
          product = Brand.find(params[:brand_id]).products.new(product_params)

          if product.save
            render json: product, status: :created
          else
            render json: product.errors, status: :unprocessable_content
          end
        end

        def update
          if @product.update(product_params)
            render json: @product
          else
            render json: @product.errors, status: :unprocessable_content
          end
        end

        def destroy
          if @product.destroy
            head :no_content
          else
            render json: @product.errors, status: :unprocessable_content
          end
        end

        def state
          if @product.update(state: params[:state])
            render json: @product
          else
            render json: @product.errors, status: :unprocessable_content
          end
        rescue ArgumentError
          render json: { error: "Invalid state" }, status: :unprocessable_content
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