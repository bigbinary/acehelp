# frozen_string_literal: true

class Mutations::LoginMutations
  Login = GraphQL::Relay::Mutation.define do
    name "LoginUser"

    input_field :email, !types.String
    input_field :password, !types.String

    return_field :user, Types::UserType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      user = User.find_by_email(inputs[:email])
      if user
        if user.valid_password?(inputs[:password])
          context[:warden].logout(:user)
          context[:warden].set_user(user)
        else
          errors = Utils::ErrorHandler.new.error("You have entered an invalid username or password", context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Email is not registered with our system", context)
      end
      {
        user: user,
        errors: errors
      }
    }

  end

  Logout = GraphQL::Relay::Mutation.define do
    return_field :errors, types[Types::ErrorType]
    return_field :status, types.Boolean

    resolve ->(object, inputs, context) {
      if context[:current_user].present?
        user = context[:warden].instance_variable_get(:@users).delete(:user)
        context[:warden].session_serializer.delete(:user, user)
      else
        errors = Utils::ErrorHandler.new.error("There is no logged in user present.", context)
      end
      {
        status: "success",
        errors: errors
      }
    }

  end
end
