# frozen_string_literal: true

class Resolvers::UrlsSearch < GraphQL::Function
  type !types[Types::UrlType]

  argument :url, types.String

  def call(obj, args, context)
    query = Url.for_organization(context[:organization])

    url = args[:url]
    url.present? ? query.where(url: url) : query
  end
end
