# frozen_string_literal: true

Types::TicketStatusEnumType = GraphQL::EnumType.define do
  name "TicketStatuses"
  description "Supported States for Ticket"
  value("OPEN", value: :open)
  value("PENDING_ON_CUSTOMER", value: :pending_on_customer)
  value("RESOLVED", value: :resolved)
  value("CLOSED", value: :closed)
end
