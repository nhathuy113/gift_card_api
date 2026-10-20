module Api
  module V1
    module Admin
      class AuditLogsController < BaseController
        def index
          logs = filtered_logs.order(created_at: :desc, id: :desc)
          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || 20).to_i

          render json: {
            audit_logs: AuditLogSerializer.new(logs.offset((page - 1) * per_page).limit(per_page)),
            page: page,
            per_page: per_page,
            total: logs.count
          }
        end

        private

        def filtered_logs
          AuditLog.by_user(params[:user_id])
            .by_action(request.query_parameters[:action])
            .by_record(params[:record_type])
            .from_date(params[:from])
            .to_date(params[:to])
        end
      end
    end
  end
end
