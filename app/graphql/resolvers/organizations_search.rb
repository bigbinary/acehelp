# frozen_string_literal: true

class Resolvers::OrganizationsSearch < GraphQL::Function
  WIDGET_CLIENT_REQUEST_HEADER = "widget"

  type Types::OrganizationType


  def call(obj, args, context)
    organization = Organization.includes(:setting).find_by(api_key: context[:organization].api_key)
    request = context[:request]
    request_headers = request && request.headers
    client_request_header = request_headers && request_headers["X-Client"]

    if organization && client_request_header == WIDGET_CLIENT_REQUEST_HEADER
      organization.setting.update_attributes!(widget_installed: true)
    end

    organization
  end
end
