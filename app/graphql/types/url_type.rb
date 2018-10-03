# frozen_string_literal: true

Types::UrlType = GraphQL::ObjectType.define do
  name "Url"
  field :id, !types.String
  field :url_rule, !types.String
  field :url_pattern, !types.String
  field :url, -> { types.String } do
    resolve -> (_, _, context) { "Unused URL field" }
  end
  field :articles, -> { !types[Types::ArticleType] } do
    preload :articles
    preload_scope ->(args, context) { Article.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.articles }
  end
end
