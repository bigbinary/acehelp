# frozen_string_literal: true

Types::UserType = GraphQL::ObjectType.define do
  name "User"

  field :id, !types.ID
  field :email, !types.String
  field :first_name, !types.String
  field :last_name, types.String
  field :role, types.String

  field :name, -> { !types.String } do
    resolve -> (obj, args, context) { obj.name }
  end
end
