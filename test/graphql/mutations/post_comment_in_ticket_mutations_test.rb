# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::PostCommentInTicketMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    sign_in @agent
    @comment_info = "Comment about a ticket by agent #{@agent.name}"
    @mutation_query = <<-GRAPHQL
      mutation($input: UpdateTicketInput!) {
          updateTicket(input: $input) {
            ticket {
              id
              status
              agent {
                id
              }
              comments {
                info
              }
            }
            errors {
              message
              path
            }
          }
      }
    GRAPHQL


  end

  test "post comment" do
    result = AceHelp::Client.execute(@mutation_query, input: {
      id: @ticket.id,
      comment: @comment_info
    })
    @ticket.reload
    assert_equal @comment_info, result.data.update_ticket.ticket.comments.last.info
    assert_kind_of String, result.data.update_ticket.ticket.id
    assert_equal @ticket.id, result.data.update_ticket.ticket.id
    assert_equal @agent.id, @ticket.agent.id
  end

  test "auto assign agent to ticket" do
    result =
      AceHelp::Client.execute(@mutation_query, input: {
        id: @ticket.id,
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    @ticket.reload
    assert_equal @agent.id, @ticket.agent.id
  end

  test "post comment without ticket_id" do
    assert_raise(Graphlient::Errors::ServerError) do
      AceHelp::Client.execute(@mutation_query, input: {
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment as a user" do
    @user = users :brad
    sign_out @agent
    sign_in @user
    @ticket.update status: Ticket.statuses[:resolved]
    assert_equal Ticket.statuses[:resolved], @ticket.status
    result = AceHelp::Client.execute(@mutation_query, input: {
      id: @ticket.id,
      comment: "Comment about a ticket by a user #{@agent.name}"
    })
    assert_equal @ticket.status, result.data.update_ticket.ticket.status
  end
end
