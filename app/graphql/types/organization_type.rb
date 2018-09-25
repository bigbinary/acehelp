# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name "Organization"
  field :id, !types.String
  field :name, !types.String
  field :email, !types.String
  field :api_key, !types.String

  field :articles, -> { !types[Types::ArticleType] }  do
    preload :articles
    resolve -> (org, args, context) { org.articles }
  end

  field :urls, -> { !types[Types::UrlType] }  do
    preload :urls
    resolve -> (org, args, context) { org.urls }
  end

  field :widget_visibility, -> { !types.Boolean } do
    preload :setting
    resolve -> (org, args, context) { org.setting.enable? }
  end
end
