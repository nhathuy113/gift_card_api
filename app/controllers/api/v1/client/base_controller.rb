module Api
  module V1
    module Client
      class BaseController < ApplicationController
        before_action :require_client!
      end
    end
  end
end
