# frozen_string_literal: true

class Mutations::AssignUserToOrganizationMutations
  Assign = GraphQL::Relay::Mutation.define do
    name "AssignUserToOrganization"

    input_field :email, !types.String
    input_field :name, types.String

    return_field :user, Types::UserType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      user = User.find_or_create_by(email: inputs[:email]) do |user|
        user.name = inputs[:name]
        user.password = user.password_confirmation =  Devise.friendly_token.first(8)
      end

      if user.blank?
        errors = Utils::ErrorHandler.new.error("User not found/created", context)
      else
        user.assign_organization(context[:organization])
      end
      {
        user: user,
        errors: errors
      }
    }
  end
end