# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::AssignTicketToAgentMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    sign_in @agent
    @agent.organizations << (organizations :bigbinary)
    @query = <<-GRAPHQL
              mutation($ticket_agent: AssignTicketToAgentInput!) {
                  assignTicketToAgent(input: $ticket_agent) {
                    status
                    errors {
                      message
                      path
                    }
                  }
              }
    GRAPHQL
  end

  test "Assigning ticket to Agent" do
    result = AceHelp::Client.execute(@query, ticket_agent: { agent_id: @agent.id, ticket_id: @ticket.id })
    assert_equal true, result.data.assign_ticket_to_agent.status
    assert_equal @agent.id, Ticket.find_by(id: @ticket.id).agent_id
  end

  test "Assigning ticket to Fake agent" do
    result = AceHelp::Client.execute(@query, ticket_agent: { agent_id: users(:hunt).id, ticket_id: @ticket.id })
    assert_nil result.data.assign_ticket_to_agent.status
  end

  test "Assigning ticket to Fake ticket" do
    result = AceHelp::Client.execute(@query, ticket_agent: { agent_id: @agent.id, ticket_id: "dummy_ticket_id" })
    assert_nil result.data.assign_ticket_to_agent.status
  end

  test "Assigning ticket to Fake ticket and agent" do
    result = AceHelp::Client.execute(@query, ticket_agent: { agent_id: users(:hunt).id, ticket_id: "dummy_ticket_id_2" })
    assert_nil result.data.assign_ticket_to_agent.status
  end
end
