# frozen_string_literal: true

class Resolvers::ArticlesSearch < GraphQL::Function
  type !types[Types::ArticleType]

  argument :id, types.String
  argument :url, types.String
  argument :status, types.String
  argument :search_string, types.String

  def call(obj, args, context)
    Article.search_using(
      context[:organization], article_id: args[:id], url: args[:url], status: args[:status], search_string: args[:search_string]
    )
  end
end
