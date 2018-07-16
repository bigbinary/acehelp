# frozen_string_literal: true

class Resolvers::ArticlesSearch < GraphQL::Function
  type !types[Types::ArticleType]

  argument :id, types.String
  argument :url, types.String

  def call(obj, args, context)
    if args[:id].present?
      if args[:url].present?
        Url.find_by(url: args[:url]).articles.where(id: args[:id]).for_organization(context[:organization])
      else
        Article.where(id: args[:id]).for_organization(context[:organization])
      end
    elsif args[:url].present?
      Url.find_by(url: args[:url]).articles.for_organization(context[:organization])
    else
      Article.for_organization(context[:organization])
    end
  end
end
