module Api
  module V1
    module Client
      class ReportsController < BaseController
        def show
          render json: Reports::ClientSpending.call(client_id: current_client.id, from: params[:from], to: params[:to])
        rescue Date::Error
          render json: { error: I18n.t("reports.invalid_date") }, status: :bad_request
        end
      end
    end
  end
end
