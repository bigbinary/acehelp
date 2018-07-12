# frozen_string_literal: true

Types::TicketType = GraphQL::ObjectType.define do
  name "Ticket"
  field :id, !types.String
  field :name, !types.String
  field :email, !types.String
  field :message, !types.String
end