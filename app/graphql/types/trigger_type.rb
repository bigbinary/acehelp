# frozen_string_literal: true

Types::TriggerType = GraphQL::ObjectType.define do
  name "Trigger"

  field :id, !types.String
  field :slug, !types.String
  field :description, types.String
  field :active, !types.Boolean
end
