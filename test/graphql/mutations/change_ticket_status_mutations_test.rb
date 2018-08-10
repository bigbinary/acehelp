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
    result = AceHelp::Client.execute(@query, ticket_args: {id: @ticket.id, status: "open"})
    assert_equal Ticket.statuses[:open], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with PENDING_ON_CUSTOMER" do
    result = AceHelp::Client.execute(@query, ticket_args: {id: @ticket.id, status: "pending_on_customer"})
    assert_equal Ticket.statuses[:pending_on_customer], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with RESOLVED" do
    result = AceHelp::Client.execute(@query, ticket_args: {id: @ticket.id, status: "resolved"})
    assert_equal Ticket.statuses[:resolved], result.data.change_ticket_status.ticket.status
  end

  test "update ticket status with CLOSED" do
    result = AceHelp::Client.execute(@query, ticket_args: {id: @ticket.id, status: "closed"})
    assert_equal Ticket.statuses[:closed], result.data.change_ticket_status.ticket.status
  end

  test "update ticket with invalid status" do
    assert_raises (ArgumentError) do
      AceHelp::Client.execute(@query, ticket_args: { id: @ticket.id, status: "NON_EXIST_STATUS" })
    end
  end
end
