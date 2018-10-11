# frozen_string_literal: true

class Resolvers::OrganizationsSearch < GraphQL::Function
  type Types::OrganizationType


  def call(obj, args, context)
    organization = Organization.includes(:setting).find_by(api_key: context[:organization].api_key)

    if organization && context[:requesting_client_is_widget]
      organization.setting.update_attributes!(widget_installed: true)
    end

    organization
  end
end
