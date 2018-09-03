# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  skip_before_action :verify_authenticity_token

  include Concerns::DeviseTokenAuthWithGraphql

  private
    def ensure_user_is_logged_in
      uid = cookies.signed[:uid]
      @resource = User.find_by(email: uid)
      unless @resource
        redirect_to users_sign_in_path
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    end
end
