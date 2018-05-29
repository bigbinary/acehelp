# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::Base
      include ::Concerns::ErrorHandlers

      rescue_from Exception, with: :handle_api_exceptions

      private

        def handle_api_exceptions(exception)
          if (exception.class.name == "ActiveRecord::RecordNotFound")
            render_not_found "Record not found"
          end
        end
    end
  end
end
