# frozen_string_literal: true

Types::ArticleType = GraphQL::ObjectType.define do
  name "Article"
  field :id, !types.ID
  field :title, !types.String
  field :desc, !types.String
  field :category, -> { Types::CategoryType }
  field :urls, -> { !types[Types::UrlType] }  do
    resolve -> (article, args, context) { article.urls.for_organization(context[:organization]) }
  end
end
