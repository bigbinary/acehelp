# frozen_string_literal: true

class Resolvers::ArticlesSearch < GraphQL::Function
  type !types[Types::ArticleType]

  argument :id, types.ID

  def call(obj, args, context)
    if args[:id].present?
        Article.where(id: args[:id]).for_organization(context[:organization])
    else
      Article.for_organization(context[:organization])
    end
  end
end
