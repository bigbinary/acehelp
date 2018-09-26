# frozen_string_literal: true

class Mutations::DismissUserMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "DismissUserFromOrganization"

    input_field :email, !types.String

    return_field :status, types.Boolean
    return_field :team, types[Types::UserType]
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      user = User.find_by(email: inputs[:email])
      err_message = case
                    when user.nil?
                      "User not found"
                    when user.organizations.blank?
                      "This user is not part of any organization"
                    when (status = user.deallocate_from_organization(context[:organization].id)).blank?
                      "Deallocation failure, Contact support"
      end
      team = User.for_organization(context[:organization]).reload
      {
        status: status,
        team: team,
        errors: err_message ? Utils::ErrorHandler.new.error(err_message, context) : []
      }
    }
  end
end
