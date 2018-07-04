# frozen_string_literal: true

Types::ErrorType = GraphQL::ObjectType.define do
  name "RichError"
  description "Used for rich error data"

  field :message, !types.String do
    resolve -> (object, args, ctx) {
      object[:message]
    }
  end
  field :path, types[types.String] do
    resolve -> (object, args, ctx) {
      object[:path]
    }
  end
end