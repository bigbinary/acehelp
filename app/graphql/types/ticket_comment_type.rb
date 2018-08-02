# frozen_string_literal: true

Types::TicketCommentType = GraphQL::ObjectType.define do
  name "TicketComment"

  field :id, !types.String
  field :agent_id, !types.String
  field :ticket_id, !types.String
  field :info, !types.String

  field :agent, -> { !Types::UserType }  do
    resolve -> (obj, args, context) { obj.agent }
  end

  field :ticket, -> { !Types::TicketType }  do
    resolve -> (obj, args, context) { obj.ticket }
  end
end
