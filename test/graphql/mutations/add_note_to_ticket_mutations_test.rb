# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::AddNoteToTicketMutationsTest < ActiveSupport::TestCase

  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    @ticket.agent_id = @agent.id
    @ticket.save
    @note = "A note is a private information that an agent puts for personal or for other agents to see"
    @query = <<-GRAPHQL
        mutation($ticket_args: AddNoteInput!) {
            addNoteToTicket(input: $ticket_args) {
              status
              errors {
                message
                path
              }
            }
        }
    GRAPHQL
  end

  test "Add note to ticket" do
    result = AceHelp::Client.execute(@query, ticket_args: {
      ticket:
        {
          agent_id: @agent.id,
         ticket_id: @ticket.id,
         note: @note
        }
    })
    assert_equal true, result.data.add_note_to_ticket.status
  end

  test "post comment without input arg : comment" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@query, ticket_args: {
        agent_id: @agent.id,
        ticket_id: @ticket.id,
        note: @note
      })
    end
  end
  test "post comment without agent_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@query, ticket_args: {
        ticket_id: @ticket.id,
        note: @note
      })
    end
  end

  test "post comment without ticket_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@query, ticket_args: {
        agent_id: @agent.id,
        note: @note
      })
    end
  end

  test "post comment without ticket_id and agent_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@query, ticket_args: {
        note: @note
      })
    end
  end
end
