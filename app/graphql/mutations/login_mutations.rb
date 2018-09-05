# frozen_string_literal: true

class Mutations::LoginMutations
  Login = GraphQL::Relay::Mutation.define do
    name "LoginUser"

    input_field :email, !types.String
    input_field :password, !types.String

    return_field :user_with_token, Types::UserWithTokenType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      user = User.find_by_email(inputs[:email])
      if user
        if user.valid_password?(inputs[:password])
          token = user.create_new_auth_token
        else
          errors = Utils::ErrorHandler.new.error("You have entered an invalid username or password", context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Email is not registered with our system", context)
      end
      {
        user_with_token: { authentication_token: token, user: user },
        errors: errors
      }
    }

  end
end
