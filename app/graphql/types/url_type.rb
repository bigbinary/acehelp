# frozen_string_literal: true

Types::UrlType = GraphQL::ObjectType.define do
  name "Url"
  field :id, !types.ID
  field :url, !types.String
  field :articles, -> { !types[Types::ArticleType] }  do
    resolve -> (url, args, context) { url.articles.for_organization(context[:organization]) }
  end
end
