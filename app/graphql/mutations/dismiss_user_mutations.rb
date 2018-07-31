# frozen_string_literal: true

class Mutations::DismissUserMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "DismissUserFromOrganization"

    input_field :email, !types.String

    return_field :status, types.Boolean
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      user = User.find_by(email: inputs[:email])
      err_message = case
                      when user.nil?
                        "User not found"
                      when user.organization_id.blank?
                        "This user is not part of any organization"
                      when user.organization_id != context[:organization].id
                        "Authorization failure. User is not a part of this organization"
                      when (status = user.deallocate_from_organization).blank?
                        "Deallocation failure, Contact support"
                    end
      {
        status: status,
        errors: err_message ? Utils::ErrorHandler.new.error(err_message, context) : []
      }
    }
  end
end
