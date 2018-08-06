# frozen_string_literal: true

Types::TicketType = GraphQL::ObjectType.define do
  name "Ticket"
  field :id, !types.String
  field :name, types.String
  field :email, !types.String
  field :message, !types.String
  field :status, !types.String
  field :agent, -> { Types::UserType }  do
    resolve -> (obj, args, context) { obj.agent }
  end
  field :note, types.String
end
