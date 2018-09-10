# frozen_string_literal: true

Types::SettingType = GraphQL::ObjectType.define do
  name "Setting"
  field :id, !types.String
  field :base_url, !types.String
  field :app_url, !types.String

  field :organization, -> { Types::OrganizationType } do
    preload :organization
    resolve ->(obj, args, context) { obj.organization }
  end
end
