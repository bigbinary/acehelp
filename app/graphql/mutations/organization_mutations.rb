# frozen_string_literal: true

class Mutations::OrganizationMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateOrganization"

    input_field :user_id, !types.String
    input_field :name, !types.String
    input_field :email, !types.String

    return_field :organization, Types::OrganizationType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      user = User.find_by!(id: inputs[:user_id])
      if user
        sanitized_params = inputs.to_h.slice("name", "email")
        new_org = user.add_organization(sanitized_params)

        if new_org
          organization = new_org
          Setting.where(organization_id: organization.id).first_or_create!
        else
          errors = Utils::ErrorHandler.new.detailed_error(new_org, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("User not found", context)
      end
      {
        organization: organization,
        errors: errors
      }
    }
  end
end
