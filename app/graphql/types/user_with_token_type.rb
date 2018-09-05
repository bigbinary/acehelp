# frozen_string_literal: true

Types::UserWithTokenType = GraphQL::ObjectType.define do
  name "UserWithTokenType"
  field :user, -> { Types::UserType } do
    resolve -> (obj, args, context) {
      obj[:user]
    }
  end

  field :authentication_token, -> { Types::TokenType } do
    resolve -> (obj, args, context) {
      obj[:authentication_token]
    }
  end
end
