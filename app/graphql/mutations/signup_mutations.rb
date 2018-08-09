# frozen_string_literal: true

class Mutations::SignupMutations
  Signup = GraphQL::Relay::Mutation.define do
    name "Signup"

    input_field :first_name, !types.String
    input_field :email, !types.String
    input_field :password, !types.String
    input_field :confirm_password, !types.String

    return_field :user, Types::UserType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      user = User.find_by(email: inputs[:email])
      if user
        errors = Utils::ErrorHandler.new.error("User with email is present", context)
      else
        if inputs[:password] == inputs[:confirmPassword]
          new_user = User.create(first_name: inputs[:firstName], password: inputs[:password], email: inputs[:email])
        else
          errors = Utils::ErrorHandler.new.error("confirm password do not match", context)
        end
      end

      {
        user: new_user,
        errors: errors
      }
    }
  end
end
