# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :addContact, field: Mutations::ContactMutations::Create.field

  field :addArticle, field: Mutations::ArticleMutations::Create.field
  field :updateArticle, field: Mutations::ArticleMutations::Update.field
  field :destroyArticle, field: Mutations::ArticleMutations::Destroy.field
  field :upvoteArticle, field: Mutations::ArticleMutations::Upvote.field
  field :downvoteArticle, field: Mutations::ArticleMutations::Downvote.field

  field :addUrl, field: Mutations::UrlMutations::Create.field
  field :updateUrl, field: Mutations::UrlMutations::Update.field
  field :destroyUrl, field: Mutations::UrlMutations::Destroy.field

  # UserMutations
  field :createUser, field: Mutations::UserMutations::Create.field
  field :createOrganization, field: Mutations::OrganizationMutations::Create.field
end
