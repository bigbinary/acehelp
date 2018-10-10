# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :addTicket, field: Mutations::TicketMutations::Create.field
  field :deleteTicket, field: Mutations::TicketMutations::Delete.field

  field :addArticle, field: Mutations::ArticleMutations::Create.field
  field :updateArticle, field: Mutations::ArticleMutations::Update.field
  field :deleteArticle, field: Mutations::ArticleMutations::Destroy.field
  field :upvoteArticle, field: Mutations::ArticleMutations::Upvote.field
  field :downvoteArticle, field: Mutations::ArticleMutations::Downvote.field
  field :updateArticleStatus, field: Mutations::ArticleMutations::UpdateStatus.field

  field :addCategory, field: Mutations::CategoryMutations::Create.field
  field :updateCategory, field: Mutations::CategoryMutations::Update.field
  field :deleteCategory, field: Mutations::CategoryMutations::Destroy.field

  field :addUrl, field: Mutations::UrlMutations::Create.field
  field :updateUrl, field: Mutations::UrlMutations::Update.field
  field :deleteUrl, field: Mutations::UrlMutations::Destroy.field

  field :addUser, field: Mutations::UserMutations::Create.field

  field :addOrganization, field: Mutations::OrganizationMutations::Create.field

  field :addFeedback, field: Mutations::FeedbackMutations::Create.field
  field :updateFeedbackStatus, field: Mutations::FeedbackMutations::UpdateStatus.field

  field :addCategoryToArticle, field: Mutations::CategoryArticleMutations::Create.field
  field :removeCategoryFromArticle, field: Mutations::CategoryArticleMutations::Destroy.field

  field :assignCategoriesToUrlPattern, field: Mutations::UrlMutations::AssignCategoryToUrlPattern.field

  field :loginUser, field: Mutations::LoginMutations::Login.field
  field :forgotPassword, field: Mutations::ForgotPasswordMutations::Perform.field
  field :signup, field: Mutations::SignupMutations::Signup.field

  field :assign_user_to_organization, field: Mutations::AssignUserToOrganizationMutations::Assign.field
  field :dismissUser, field: Mutations::DismissUserMutations::Perform.field

  field :changeTicketStatus, field: Mutations::ChangeTicketStatusMutation::Perform.field
  field :assignTicketToAgent, field: Mutations::AssignTicketToAgentMutations::Perform.field
  field :updateTicket, field: Mutations::TicketMutations::Update.field
  field :changeCategoryStatus, field: Mutations::ChangeCategoryStatusMutation::Perform.field
  field :changeTriggerStatus, field: Mutations::ChangeTriggerStatusMutation::Perform.field

  field :changeVisibilityOfWidget, field: Mutations::WidgetSettingMutation::EnableDisableWidget.field
  field :updateBaseUrlForOrganization, field: Mutations::WidgetSettingMutation::Update.field
end
