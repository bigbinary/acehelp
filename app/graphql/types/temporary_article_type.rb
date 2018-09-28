# frozen_string_literal: true

Types::TemporaryArticleType = GraphQL::ObjectType.define do
  name "TemporaryArticle"
  field :id, !types.String
end
