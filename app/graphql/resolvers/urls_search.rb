# frozen_string_literal: true

class Resolvers::UrlsSearch < GraphQL::Function
  type !types[Types::UrlType]

  argument :url, types.String

  def call(obj, args, ctx)
    if args[:url]
      Url.where(url: args[:url]).for_organization(ctx[:organization])
    else
      Url.for_organization(ctx[:organization])
    end
  end
end
