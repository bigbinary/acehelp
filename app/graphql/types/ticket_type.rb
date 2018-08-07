# frozen_string_literal: true

Types::TicketType = GraphQL::ObjectType.define do
  name "Ticket"
  field :id, !types.String
  field :name, types.String
  field :email, !types.String
  field :message, !types.String
  field :status, Types::TicketStatusEnumType
  field :note, types.String
  field :statuses, -> { types[Types::TicketStatusesType] } do
    resolve ->(obj, args, context) { Ticket::statuses }
  end
end
