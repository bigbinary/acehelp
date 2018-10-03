# frozen_string_literal: true

Types::ArticleType = GraphQL::ObjectType.define do
  name "Article"
  field :id, !types.String
  field :title, !types.String
  field :desc, !types.String
  field :upvotes_count, !types.Int
  field :downvotes_count, !types.Int
  field :status, !types.String

  field :categories, -> { !types[Types::CategoryType] } do
    preload :categories
    resolve ->(obj, args, context) { obj.categories }
  end

  field :urls, -> { !types[Types::UrlType] }  do
    preload :urls
    preload_scope ->(args, context) { Url.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.urls }
  end

  field :attachments_path, -> { !types.String }  do
    resolve ->(obj, args, context) do
      Rails.application.routes.url_helpers.organization_article_attachments_path(context[:organization], obj)
    end
  end
end
