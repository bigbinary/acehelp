# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  skip_before_action :verify_authenticity_token

  private

    def ensure_user_is_logged_in
      unless current_user
        redirect_to new_user_session_path
      end
    end

    def set_organization
      @organization = Organization.first
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    end

    def after_sign_in_path_for(resource)
      if resource.organizations.exists?
        organization_articles_path(resource.organizations.first.api_key)
      else
        root_path
      end
    end
end
