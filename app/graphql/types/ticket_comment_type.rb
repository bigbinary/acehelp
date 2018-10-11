# frozen_string_literal: true

Types::TicketCommentType = GraphQL::ObjectType.define do
  name "TicketComment"

  field :id, !types.String
  field :commentable_id, !types.String
  field :ticket_id, !types.String
  field :info, !types.String
  field :created_at, !types.String
  field :user_name, !types.String, resolve: -> (obj, args, ctx) { obj.commentable.name }

  field :commentable, -> { !Types::UserType }  do
    resolve -> (obj, args, context) { obj.commentable }
  end

  field :ticket, -> { !Types::TicketType }  do
    resolve -> (obj, args, context) { obj.ticket }
  end
end
