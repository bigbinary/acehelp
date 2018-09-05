# frozen_string_literal: true

class Mutations::ForgotPasswordMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "ForgotPassword"

    input_field :email, !types.String

    return_field :status, !types.Boolean
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      user = User.find_by_email(inputs[:email])
      if user
        user.reset_password_token
        status = true
      else
        errors = Utils::ErrorHandler.new.error("Email is not registered with our system", context)
      end

      {
        status: !!status,
        errors: errors
      }
    }
  end
end
