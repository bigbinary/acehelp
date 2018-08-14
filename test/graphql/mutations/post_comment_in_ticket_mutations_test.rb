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
      mutation($id: String, $comment: String) {
        updateTicket(input: { id: $id, comment: $comment }) {
          ticket {
            status
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
    assert_equal @comment_info, result.data.post_comment_in_ticket.comment.info
    assert_kind_of String, result.data.post_comment_in_ticket.comment.id
    assert_equal @agent.id, result.data.post_comment_in_ticket.comment.commentable.id
    assert_equal @agent.id, result.data.post_comment_in_ticket.comment.commentable.id
    assert_equal @ticket.id, result.data.post_comment_in_ticket.comment.ticket.id
    assert_equal @agent.first_name, result.data.post_comment_in_ticket.comment.ticket.agent.first_name
  end

  test "auto assign agent to ticket" do

    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, input: {
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without input arg : comment" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, input: {
        id: @ticket.id,
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without user_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, input: {
        id: @ticket.id,
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without ticket_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, input: {
        comment: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment as a user" do
    @ticket.update status: Ticket.statuses[:resolved]
    assert_equal Ticket.statuses[:resolved], @ticket.status
    result = AceHelp::Client.execute(@mutation_query, input: {
      id: @ticket.id,
      comment: "Comment about a ticket by a user #{@agent.name}"
    })
    assert_equal Ticket.statuses[:open], result.data.post_comment_in_ticket.comment.ticket.status
  end
end
