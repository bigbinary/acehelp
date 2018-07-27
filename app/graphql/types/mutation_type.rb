# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :addTicket, field: Mutations::TicketMutations::Create.field

  field :addArticle,  field: Mutations::ArticleMutations::Create.field
  field :updateArticle, field: Mutations::ArticleMutations::Update.field
  field :deleteArticle, field: Mutations::ArticleMutations::Destroy.field
  field :upvoteArticle, field: Mutations::ArticleMutations::Upvote.field
  field :downvoteArticle, field: Mutations::ArticleMutations::Downvote.field

  field :addCategory,  field: Mutations::CategoryMutations::Create.field
  field :updateCategory, field: Mutations::CategoryMutations::Update.field
  field :deleteCategory, field: Mutations::CategoryMutations::Destroy.field

  field :addUrl, field: Mutations::UrlMutations::Create.field
  field :updateUrl, field: Mutations::UrlMutations::Update.field
  field :deleteUrl, field: Mutations::UrlMutations::Destroy.field

  field :addUser, field: Mutations::UserMutations::Create.field

  field :addOrganization, field: Mutations::OrganizationMutations::Create.field

  field :addUserToOrganization, field: Mutations::OrganizationUserMutations::Create.field
  field :removeUserFromOrganization, field: Mutations::OrganizationUserMutations::Destroy.field

end
