# frozen_string_literal: true

class Resolvers::ArticlesSearch < GraphQL::Function
  type !types[Types::ArticleType]

  argument :id, types.ID

  def call(obj, args, ctx)
    if args[:id].present?
        Article.where(id: args[:id]).for_organization(ctx[:organization])
    else
      Article.for_organization(ctx[:organization])
    end
  end
end
