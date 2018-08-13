# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::TicketsSearchTest < ActiveSupport::TestCase
  setup do
    @ticket = tickets(:payment_issue_ticket)
    @organization = @ticket.organization
  end

  def find(args)
    Resolvers::TicketsSearch.new.call(nil, args, organization: @organization)
  end

  test "show ticket success" do
    assert_equal find(id: @ticket.id), [@ticket]
  end

  test "show ticket failure" do
    assert_equal find(id: -1).size, 0
  end

  test "search ticket success" do
    query = <<-'GRAPHQL'
              query {
                tickets {
                  id
                  message
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query)

    assert_equal result.data.tickets.size, 1
    assert_equal result.data.tickets.last.message, @ticket.message
  end

  test "search with status" do
    query = <<-'GRAPHQL'
              query {
                tickets(status: "open") {
                  id
                  message
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query)

    assert_equal result.data.tickets.size, 1
    assert_equal result.data.tickets.last.message, @ticket.message
  end
end
