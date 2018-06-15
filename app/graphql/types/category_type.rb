# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name "Category"
  field :id, !types.ID
  field :name, !types.String
  field :articles, -> { !types[Types::ArticleType] }  do
    resolve -> (category, args, context) { category.articles.for_organization(context[:organization]) }
  end
end
