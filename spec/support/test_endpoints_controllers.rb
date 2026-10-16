module Api
  module V1
    module Admin
      class TestEndpointsController < BaseController
        def index
          render json: { message: "admin ok" }
        end
      end
    end

    module Client
      class TestEndpointsController < BaseController
        def index
          render json: { message: "client ok" }
        end
      end
    end
  end
end
