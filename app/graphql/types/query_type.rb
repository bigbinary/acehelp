# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :articles, function: Resolvers::ArticlesSearch.new
  field :all, function: Resolvers::CategoriesSearch.new
  field :urls, function: Resolvers::UrlsSearch.new

  field :article, Types::ArticleType, field: Resolvers::Fields::FetchField.build(type: Types::ArticleType, model: Article)
  field :url, Types::UrlType, field: Resolvers::Fields::FetchField.build(type: Types::UrlType, model: Url)
end
