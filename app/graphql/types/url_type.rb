# frozen_string_literal: true

Types::UrlType = GraphQL::ObjectType.define do
  name "Url"
  field :id, !types.ID
  field :url, !types.String

  field :articles, -> { !types[Types::ArticleType] } do
    preload :articles
    preload_scope ->(args, context) { Article.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.articles }
  end
end
