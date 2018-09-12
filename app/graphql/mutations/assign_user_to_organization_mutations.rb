# frozen_string_literal: true

class Mutations::AssignUserToOrganizationMutations
  Assign = GraphQL::Relay::Mutation.define do
    name "AssignUserToOrganization"

    input_field :email, !types.String
    input_field :firstName, types.String
    input_field :lastName, types.String

    return_field :user, Types::UserType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      raise GraphQL::ExecutionError, "Not Loggedin" unless context[:current_user]["id"]
      user = User.find_or_create_by(email: inputs[:email]) do |user|
        user.first_name = inputs[:firstName]
        user.last_name = inputs[:lastName]
        user.password = user.password_confirmation = Devise.friendly_token.first(8)
      end

      if user.blank?
        errors = Utils::ErrorHandler.new.error("User not found/created", context)
      else
        user.assign_organization(context[:organization])
        user.send_welcome_mail(sender_id: context[:current_user]["id"], org_id: context[:organization].id)
      end
      {
        user: user,
        errors: errors
      }
    }
  end
end
