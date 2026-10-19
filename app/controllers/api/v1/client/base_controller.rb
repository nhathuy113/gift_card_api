module Api
  module V1
    module Client
      class BaseController < ApplicationController
        before_action :require_client!

        private

        def current_client
          @current_client ||= current_user.becomes(::Client)
        end
      end
    end
  end
end
