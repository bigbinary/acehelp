# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::PostCommentInTicketMutationsTest < ActiveSupport::TestCase
  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    @user = users(:hunt)
    @comment_info = "Comment about a ticket by agent #{@agent.name}"
    @mutation_query = <<-GRAPHQL
      mutation($comment_args: PostCommentInput!) {
        postCommentInTicket(input: $comment_args) {
          comment {
            id
            info
            commentable {
              id
              name
            }
            ticket {
              id
              agent {
                first_name
              }
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
        { user_id: @agent.id,
          ticket_id: @ticket.id,
          info: @comment_info
        }
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
      AceHelp::Client.execute(@mutation_query, comment_args: {
        agent_id: @agent.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without input arg : comment" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, comment_args: {
        user_id: @agent.id,
        ticket_id: @ticket.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment without user_id" do
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
        user_id: @agent.id,
        info: "Comment about a ticket by agent #{@agent.name}"
      })
    end
  end

  test "post comment as a user" do
    @ticket.update status: Ticket::STATUSES[:resolved]
    assert_equal Ticket::STATUSES[:resolved], @ticket.status
    result = AceHelp::Client.execute(@mutation_query, comment_args: {comment: {
      user_id: @user.id,
      ticket_id: @ticket.id,
      info: "Comment about a ticket by a user #{@agent.name}"
    }})
    assert_equal Ticket::STATUSES[:open], result.data.post_comment_in_ticket.comment.ticket.status
  end


end
