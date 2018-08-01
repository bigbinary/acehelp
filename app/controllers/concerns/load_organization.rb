# frozen_string_literal: true

module LoadOrganization
  extend ActiveSupport::Concern

  included do
    before_action :load_organization
  end

  def load_organization
    api_key = request.headers["api-key"] || params["organization_api_key"]

    if api_key.blank?
      if Rails.env.development?
        @organization = Organization.first
        return
      end

      render_unauthorized(unathorized_error_message)
    else
      @organization = Organization.find_by(api_key: api_key)
      render_unauthorized(unathorized_error_message) && return if @organization.blank?
    end
  end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid API Key"
    end
end
