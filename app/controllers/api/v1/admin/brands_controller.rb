module Api
  module V1
    module Admin
      class BrandsController < BaseController
        before_action :set_brand, only: %i[show update state]

        def index
          render json: Brand.order(:name)
        end

        def show
          render json: @brand
        end

        def create
          brand = Brand.new(brand_params)

          if brand.save
            render json: brand, status: :created
          else
            render json: brand.errors, status: :unprocessable_content
          end
        end

        def update
          if @brand.update(brand_params)
            render json: @brand
          else
            render json: @brand.errors, status: :unprocessable_content
          end
        end

        def state
          if @brand.update(state: params[:state])
            render json: @brand
          else
            render json: @brand.errors, status: :unprocessable_content
          end
        rescue ArgumentError
          render json: { error: "Invalid state" }, status: :unprocessable_content
        end

        private

        def set_brand
          @brand = Brand.find(params[:id])
        end

        def brand_params
          params.permit(:name, custom_fields: %i[name value])
        end
      end
    end
  end
end
