# frozen_string_literal: true

Types::FeedbackType = GraphQL::ObjectType.define do
  name "Feedback"
  field :id, !types.String
  field :name, types.String
  field :message, !types.String
end