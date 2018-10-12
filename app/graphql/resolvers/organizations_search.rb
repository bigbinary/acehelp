# frozen_string_literal: true

class Resolvers::OrganizationsSearch < GraphQL::Function
  type Types::OrganizationType

  def call(obj, args, context)
    criterion = { api_key: context[:organization].api_key }
    organization = Organization.includes(:setting).find_by(criterion)

    set_widget_installed(organization) if request_issued_by_widget?(context)

    organization
  end

  private

    def set_widget_installed(organization)
      if organization
        organization.setting.update_attributes!(widget_installed: true)
      end
    end

    def request_issued_by_widget?(context)
      context[:request_source] == Utils::Constants::REQUEST_SOURCE_WIDGET
    end
end
