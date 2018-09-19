# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  skip_before_action :verify_authenticity_token

  private

    def ensure_user_is_logged_in
      p "--------------------------------------------"
      p warden.session
      p "--------------------------------------------"
      p warden.user
      p "--------------------------------------------"
      p user_signed_in?
      p "--------------------------------------------"

      unless user_signed_in?
        redirect_to new_user_session_path
      end
        end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    end
end
