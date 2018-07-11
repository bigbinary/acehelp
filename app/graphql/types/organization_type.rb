# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name "Organization"
  field :id, !types.String
  field :name, !types.String
  field :articles, -> { !types[Types::ArticleType] }  do
    resolve -> (org, args, context) { org.articles }
  end

  field :urls, -> { !types[Types::UrlType] }  do
    resolve -> (org, args, context) { org.urls }
  end
end
