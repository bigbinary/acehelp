# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name "Category"
  field :id, !types.ID
  field :name, !types.String
  field :articles, -> { !types[Types::ArticleType] }  do
    resolve -> (category, args, ctx) { category.articles.for_organization(ctx[:organization]) }
  end
end
