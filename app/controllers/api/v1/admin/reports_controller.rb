module Api
  module V1
    module Admin
      class ReportsController < BaseController
        def brands
          render json: Reports::ByBrand.call(from: params[:from], to: params[:to])
        rescue Date::Error
          render json: { error: I18n.t("reports.invalid_date") }, status: :bad_request
        end

        def clients
          render json: Reports::ByClient.call(from: params[:from], to: params[:to])
        rescue Date::Error
          render json: { error: I18n.t("reports.invalid_date") }, status: :bad_request
        end
      end
    end
  end
end
