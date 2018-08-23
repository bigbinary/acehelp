# frozen_string_literal: true

class Resolvers::SearchArticles < GraphQL::Function
  type !types[Types::ArticleType]

  argument :search_string, !types.String

  def call(obj, args, context)
    Article.search_by(args[:search_string], context[:organization])
  end
end
