# frozen_string_literal: true

Types::TicketNoteType = GraphQL::ObjectType.define do
  name "TicketNote"

  field :id, !types.String
  field :agent_id, !types.String
  field :ticket_id, !types.String
  field :details, !types.String

  field :ticket, -> { !Types::TicketType }  do
    resolve -> (obj, args, context) { obj.ticket }
  end
end
