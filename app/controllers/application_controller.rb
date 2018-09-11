# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  skip_before_action :verify_authenticity_token

  private
    def ensure_user_is_logged_in
      email = warden.user["email"] if warden.user
      @resource = User.find_by(email: email)
      if @resource
        new_organization_path if @resource.organizations.empty?
      else
        redirect_to users_sign_in_path
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    end
end
