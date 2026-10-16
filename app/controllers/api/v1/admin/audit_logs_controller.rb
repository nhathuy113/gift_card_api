module Api
  module V1
    module Admin
      class AuditLogsController < BaseController
        def index
          logs = AuditLog.order(created_at: :desc, id: :desc)
                         .by_user(params[:user_id])
                         .by_action(params[:log_action])
                         .by_record(params[:record_type])
                         .from_date(params[:from])
                         .to_date(params[:to])

          per = params.fetch(:per_page, 25).to_i.clamp(1, 100)
          page = [params.fetch(:page, 1).to_i, 1].max

          render json: {
            data: logs.offset((page - 1) * per).limit(per),
            meta: { page: page, per_page: per }
          }
        rescue Date::Error, ArgumentError
          render json: { error: "Invalid date format" }, status: :bad_request
        end
      end
    end
  end
end
