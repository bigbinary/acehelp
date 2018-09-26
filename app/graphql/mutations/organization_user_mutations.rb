# frozen_string_literal: true

class Mutations::OrganizationUserMutations
  Create = GraphQL::Relay::Mutation.define do
    name "AddUserToOrganization"

    input_field :organization_id, !types.String
    input_field :user_id, !types.String
    input_field :role, !types.String

    return_field :organization_user, Types::OrganizationUserType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      user = User.find_by_id(inputs[:user_id])
      organization = organization.find_by_id(inputs[:organization_id])

      if user.blank?
        errors = Utils::ErrorHandler.new.error("User not found", context)
      elsif organization.blank?
        errors = Utils::ErrorHandler.new.error("Organization not found", context)
      elsif OrganizationUser.exists?(organization_id: organization.id, user_id: user.id)
        errors = Utils::ErrorHandler.new.error("Record already exists for given user and organization", context)
      else
        new_organization_user = OrganizationUser.create organization_id: organization.id,
                                                    user_id: user.id,
                                                    role: inputs[:role]

        if new_organization_user.save
          organization_user = new_organization_user
        else
          errors = Utils::ErrorHandler.new.detailed_error(new_organization_user, context)
        end
      end

      {
        organization_user: organization_user,
        errors: errors
      }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "RemoveUserFromOrganization"

    input_field :organization_id, !types.String
    input_field :user_id, !types.String

    return_field :organization_user, Types::OrganizationUserType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      user = User.find_by_id(inputs[:user_id])
      organization = organization.find_by_id(inputs[:organization_id])

      if user.blank?
        errors = Utils::ErrorHandler.new.error("User not found", context)
      elsif organization.blank?
        errors = Utils::ErrorHandler.new.error("Organization not found", context)
      elsif OrganizationUser.where(organization_id: organization.id, user_id: user.id).first.blank?
        errors = Utils::ErrorHandler.new.error("Record does not exist for given user and organization", context)
      else

        organization_user = OrganizationUser.where(organization_id: organization.id, user_id: user.id).first

        if organization_user.destroy
          # noop
        else
          errors = Utils::ErrorHandler.new.detailed_error(organization_user, context)
        end
      end

      {
        organization_user: organization_user,
        errors: errors
      }
    }
  end
end
