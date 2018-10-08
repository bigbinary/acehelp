# frozen_string_literal: true

Types::CategoryType = GraphQL::ObjectType.define do
  name "Category"
  field :id, !types.String
  field :name, !types.String
  field :status, !types.String

  field :articles, -> { !types[Types::ArticleType] }  do
    preload :articles
    preload_scope ->(args, context) { Article.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.articles }
  end

  field :urls, -> { !types[Types::UrlType] }  do
    preload :urls
    resolve -> (obj, args, context) { obj.urls }
  end
end
