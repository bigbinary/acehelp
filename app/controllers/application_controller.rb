# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_app_url

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

    def ensure_user_is_logged_in
      unless user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    end

    def after_sign_out_path_for(resource)
      root_path
    end

    def load_app_url
      @app_url = AppUrlCarrier.app_url(request)
    end
end
