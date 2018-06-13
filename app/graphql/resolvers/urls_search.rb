# frozen_string_literal: true

class Resolvers::UrlsSearch < GraphQL::Function
  type !types[Types::UrlType]

  argument :url, types.String

  def call(obj, args, context)
    if args[:url]
      Url.where(url: args[:url]).for_organization(context[:organization])
    else
      Url.for_organization(context[:organization])
    end
  end
end
