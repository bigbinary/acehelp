# frozen_string_literal: true

Types::TicketStatusesType = GraphQL::ObjectType.define do
  name "TicketStatusesList"
  description "Supported States for Ticket"
  field :key, -> { types.String } do
    resolve ->(obj, args, context) { obj[0] }
  end
  field :value, -> { types.String } do
    resolve ->(obj, args, context) { obj[1] }
  end
end
