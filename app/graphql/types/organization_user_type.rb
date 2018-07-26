# frozen_string_literal: true

Types::OrganizationUserType = GraphQL::ObjectType.define do
  name "OrganizationUser"

  field :id, !types.String
  field :role, !types.String

  field :organization, -> { Types::OrganizationType } do
    preload :organization
    resolve ->(obj, args, context) { obj.organization }
  end

  field :user, -> { Types::UserType } do
    preload :user
    resolve ->(obj, args, context) { obj.user }
  end

end
