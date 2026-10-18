module Api
  module V1
    module Admin
      class BrandsController < BaseController
        before_action :set_brand, only: %i[show update state]

        def index
          render json: BrandSerializer.new(Brand.order(:name))
        end

        def show
          render json: BrandSerializer.new(@brand)
        end

        def create
          brand = Brand.new(brand_params)
          return render json: brand.errors, status: :unprocessable_entity unless brand.save

          render json: BrandSerializer.new(brand), status: :created
        end

        def update
          return render json: @brand.errors, status: :unprocessable_entity unless @brand.update(brand_params)

          render json: BrandSerializer.new(@brand)
        end

        def state
          return render json: @brand.errors, status: :unprocessable_entity unless @brand.update(state: params[:state])

          render json: BrandSerializer.new(@brand)
        rescue ArgumentError
          render json: { error: "Invalid state" }, status: :unprocessable_entity
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
