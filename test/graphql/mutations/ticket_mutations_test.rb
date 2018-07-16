# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::TicketMutationsTest < ActiveSupport::TestCase
  test "create ticket mutations" do
    query = <<-'GRAPHQL'
              mutation($input: CreateTicketInput!) {
                addTicket(input: $input) {
                  ticket {
                    id
                    name
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: {  name: "Ticket_name",
                                                      email: "contact@email.com",
                                                      message: "Dummy" })

    assert_equal result.data.add_ticket.ticket.name, "Ticket_name"
  end

  test "create ticket mutations with optinal name input" do
    query = <<-'GRAPHQL'
              mutation($input: CreateTicketInput!) {
                addTicket(input: $input) {
                  ticket {
                    id
                    name
                    email
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: {  name: "",
                                                      email: "contact@email.com",
                                                      message: "Dummy" })

    assert_equal result.data.add_ticket.ticket.email, "contact@email.com"
  end

  test "create ticket mutations failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateTicketInput!) {
                addTicket(input: $input) {
                  ticket {
                    id
                    name
                  }
                  errors {
                    message
                    path
                  }
                }
              }
            GRAPHQL
    result = AceHelp::Client.execute(query, input: {  name: "",
                                                      email: "",
                                                      message: "Dummy" })
    assert_nil result.data.add_ticket.ticket
  end

  test "create ticket mutation error failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateTicketInput!) {
                addTicket(input: $input) {
                  ticket {
                    id
                  }
                  errors {
                    message
                    path
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: { name: "", email: "", message: "Dummy" })
    assert_not_empty result.data.add_ticket.errors.flat_map(&:path) & ["addTicket", "email"]
  end
end
