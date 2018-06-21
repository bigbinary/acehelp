# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::Base
      include ::Concerns::ErrorHandlers

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      skip_before_action :verify_authenticity_token
    end
  end
end
