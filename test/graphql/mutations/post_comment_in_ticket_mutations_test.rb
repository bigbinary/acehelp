# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::PostCommentInTicketMutationsTest < ActiveSupport::TestCase
  setup do
    @ticket = tickets(:payment_issue_ticket)
    @agent = agents(:illya_kuryakin)
    @agent.password = @agent.password_confirmation = "SelfDestructIn5"
    @agent.save
    @comment_info = "Comment about a ticket by agent #{@agent.name}"
    login_query = <<-GRAPHQL
      mutation($login_keys: LoginUserInput!) {
          loginUser(input: $login_keys) {
            user_with_token {
              authentication_token {
                client
                access_token
                uid
              }
            }
            errors {
              message
              path
            }
          }
      }
    GRAPHQL
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
    AceHelp::Client.execute(login_query, login_keys: { email: @agent.email, password: "SelfDestructIn5" })
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
    result = AceHelp::Client.execute(@mutation_query, input: {
      comment: "Comment about a ticket by agent #{@agent.name}"
    })
    assert_kind_of GraphQL::Client::Errors, result.data.errors
  end

  test "post comment as a user" do
    @user = users :brad
    @ticket.update status: Ticket.statuses[:resolved]
    assert_equal Ticket.statuses[:resolved], @ticket.status
    result = AceHelp::Client.execute(@mutation_query, input: {
      id: @ticket.id,
      comment: "Comment about a ticket by a user #{@agent.name}"
    })
    assert_equal @ticket.status, result.data.update_ticket.ticket.status
  end
end
