# frozen_string_literal: true

Types::ArticleType = GraphQL::ObjectType.define do
  name "Article"
  field :id, !types.ID
  field :title, !types.String
  field :desc, !types.String

  field :category, -> { Types::CategoryType } do
    preload :category
    resolve ->(obj, args, context) { obj.category }
  end

  field :urls, -> { !types[Types::UrlType] }  do
    preload :urls
    preload_scope ->(args, context) { Url.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.urls }
  end
end
