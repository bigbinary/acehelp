# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::PostCommentInTicketMutationsTest < ActiveSupport::TestCase
  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    @comment_info = "Comment about a ticket by agent #{@agent.name}"
    @mutation_query = <<-GRAPHQL
      mutation($comment_args: PostCommentInput!) {
        postCommentInTicket(input: $comment_args) {
          comment {
            id
            info
            agent {
              id
              name
            }
            ticket {
              id
            }
          }
          errors {
            path
            message
          }
        }
      }
    GRAPHQL


  end

  test "post comment" do
    result = AceHelp::Client.execute(@mutation_query, comment_args: {
      comment:
        { agent_id: @agent.id,
          ticket_id: @ticket.id,
          info: @comment_info
        }
    })
    assert_equal @comment_info, result.data.post_comment_in_ticket.comment.info
    assert_kind_of String, result.data.post_comment_in_ticket.comment.id
    assert_equal @agent.id, result.data.post_comment_in_ticket.comment.agent.id
    assert_equal @agent.id, result.data.post_comment_in_ticket.comment.agent.id
    assert_equal @ticket.id, result.data.post_comment_in_ticket.comment.ticket.id
  end

  test "post comment without input arg : comment" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, comment_args: {
        agent_id: @agent.id,
        ticket_id: @ticket.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without agent_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, comment_args: {
        ticket_id: @ticket.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without ticket_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, comment_args: {
        agent_id: @agent.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end



end
