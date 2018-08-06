# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ChangeTicketMutationsTest < ActiveSupport::TestCase

  setup do
    @ticket = tickets(:payment_issue_ticket)
    @query = <<-GRAPHQL
        mutation($ticket_args: ChangeTicketStatusInput!) {
          changeTicketStatus(input: $ticket_args) {
            ticket {
              id
              status
            }
            errors {
              path
              message
            }
          }
        }
    GRAPHQL
  end

  test "update ticket status with OPEN" do
    result = AceHelp::Client.execute(@query, ticket_args: {ticket_id: @ticket.id, status: "OPEN"})
    assert_equal Ticket::STATUSES[:open], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with PENDING_ON_CUSTOMER" do
    result = AceHelp::Client.execute(@query, ticket_args: {ticket_id: @ticket.id, status: "PENDING_ON_CUSTOMER"})
    assert_equal Ticket::STATUSES[:pending_on_customer], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with RESOLVED" do
    result = AceHelp::Client.execute(@query, ticket_args: {ticket_id: @ticket.id, status: "RESOLVED"})
    assert_equal Ticket::STATUSES[:resolved], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with CLOSED" do
    result = AceHelp::Client.execute(@query, ticket_args: {ticket_id: @ticket.id, status: "CLOSED"})
    assert_equal Ticket::STATUSES[:closed], result.data.change_ticket_status.ticket.status
  end

  test "update ticket with invalid status" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@query, ticket_args: {ticket_id: @ticket.id, status: "NON_EXIST_STATUS"})
    end
  end
end
