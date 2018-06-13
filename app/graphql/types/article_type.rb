# frozen_string_literal: true

Types::ArticleType = GraphQL::ObjectType.define do
  name "Article"
  field :id, !types.ID
  field :title, !types.String
  field :desc, !types.String
  field :category, -> { Types::CategoryType }
  field :urls, -> { !types[Types::UrlType] }  do
    resolve -> (article, args, ctx) { article.urls.for_organization(ctx[:organization]) }
  end
end
