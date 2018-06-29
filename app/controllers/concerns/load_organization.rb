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
      api_key = request.headers["api-key"]

      render_unauthorized_request(err: :missing_keys) && return if api_key.blank?
      @organization = Organization.find_by(api_key: api_key)
    end

    render_unauthorized_request(err: :missing_keys) && return if api_key.blank?
    @organization = Organization.find_by(api_key: api_key)
    render_unauthorized_request && return if @organization.blank?
  end

  private

    def graphql_api_call?
      params[:controller] == "graphql"
    end

    def render_unauthorized_request(err: :invalid_keys)
      err_text = "UNAUTHORIZED REQUEST: #{err.to_s.titleize}"
      if graphql_api_call?
        render_unauthorized_org_error_graphql(err_text)
      else
        render_unauthorized(err_text)
      end
    end

    def render_unauthorized_org_error_graphql(message)
      render json: Utils::ErrorHandler.new.generate_graphql_error_with_root(message,
                                                           path: "load_organization",
                                                           extensions: { code: "UNAUTHORIZED" })
    end
end
