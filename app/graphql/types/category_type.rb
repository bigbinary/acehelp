# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name "Category"
  field :id, !types.ID
  field :name, !types.String

  field :articles, -> { !types[Types::ArticleType] }  do
    preload :articles
    preload_scope ->(args, context) { Article.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.articles }
  end
end
