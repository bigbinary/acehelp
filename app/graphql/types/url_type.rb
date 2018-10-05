# frozen_string_literal: true

Types::UrlType = GraphQL::ObjectType.define do
  name "Url"
  field :id, !types.String
  field :url_rule, !types.String
  field :url_pattern, -> { !types.String } do
    resolve ->(obj, args, context) {
      obj.change_url_pattern_to_placeholder
    }
  end
  field :articles, -> { !types[Types::ArticleType] } do
    preload :articles
    preload_scope ->(args, context) { Article.for_organization(context[:organization]) }
    resolve ->(obj, args, context) { obj.articles }
  end
end
