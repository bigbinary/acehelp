# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :articles, function: Resolvers::ArticlesSearch.new
  field :categories, function: Resolvers::CategoriesSearch.new
  field :urls, function: Resolvers::UrlsSearch.new

  field :article, Types::ArticleType,
                  field: Resolvers::Fields::FetchField.build(type: Types::ArticleType,
                                                             model: Article)

  field :url, Types::UrlType,
              field: Resolvers::Fields::FetchField.build(type: Types::UrlType,
                                                         model: Url)
  field :organization, Types::OrganizationType,
                       field: Resolvers::Fields::FetchField.build(type: Types::OrganizationType,
                                                                  model: Organization)

  field :ticket, Types::TicketType,
                 field: Resolvers::Fields::FetchField.build(type: Types::TicketType,
                                                            model: Ticket)
  field :category, Types::CategoryType, field: Resolvers::Fields::FetchField.build(type: Types::CategoryType, model: Category)
end
