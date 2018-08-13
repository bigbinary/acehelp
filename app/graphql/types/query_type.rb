# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :articles,    function: Resolvers::ArticlesSearch.new
  field :categories,  function: Resolvers::CategoriesSearch.new
  field :urls,        function: Resolvers::UrlsSearch.new
  field :tickets,     function: Resolvers::TicketsSearch.new
  field :feedbacks,   function: Resolvers::FeedbacksSearch.new
  field :users,   function: Resolvers::UsersSearch.new

  hash = { type: Types::ArticleType, model: Article }
  field :article, Types::ArticleType,
                  field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::UrlType, model: Url }
  field :url, Types::UrlType, field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::OrganizationType, model: Organization }
  field :organization, Types::OrganizationType,
                       field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::TicketType, model: Ticket }
  field :ticket, Types::TicketType,
                 field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::CategoryType, model: Category }
  field :category, Types::CategoryType, field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::FeedbackType, model: Feedback }
  field :feedback, Types::FeedbackType, field: Resolvers::Fields::FetchField.build(hash)

  hash = { type: Types::UserType, model: User }
  field :user, Types::UserType,
                  field: Resolvers::Fields::FetchField.build(hash)

end
