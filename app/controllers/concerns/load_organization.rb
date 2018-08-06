# frozen_string_literal: true

module LoadOrganization
  extend ActiveSupport::Concern

  included do
    before_action :load_organization
  end

  def load_organization
    api_key = request.headers["api-key"] || params["organization_api_key"]
    return if api_key.nil?
    @organization = Organization.find_by(api_key: api_key)
    render_unauthorized(unathorized_error_message) && return if @organization.blank?
  end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid API Key"
    end
end
