# frozen_string_literal: true

Types::UserType = GraphQL::ObjectType.define do
  name "User"

  field :id, !types.String
  field :email, !types.String
  field :first_name, types.String
  field :last_name, types.String
  field :role, types.String
  field :organization_id, types.String
  field :organizations, types[Types::OrganizationType]

  field :name, -> { types.String } do
    resolve -> (obj, args, context) { obj.name }
  end
  field :organization, -> { Types::OrganizationType } do
    resolve -> (obj, args, context) {
      if obj.organizations.exists?
        obj.organizations.first
      end
    }
  end
end
