# frozen_string_literal: true

module LoadOrganization
  extend ActiveSupport::Concern

  included do
    before_action :load_organization
  end

  def load_organization
    if Rails.env.development?
      @organization = Organization.first
    else
      @organization = Organization.find_by(api_key: request.headers["api-key"])
    end

    render_unauthorized("Unauthorized request") && return unless @organization
  end
end
