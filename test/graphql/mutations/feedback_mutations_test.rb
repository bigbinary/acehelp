# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::OrganizationMutationsTest < ActiveSupport::TestCase
  setup do
    @mutation_query = <<-GRAPHQL
      mutation($feedback: CreateFeedbackInput!) {
        addFeedback(input: $feedback) {
          feedback {
            id
            name
            message
          }
        }
      }
    GRAPHQL
  end

  test "create feedback" do
    article = articles(:life)
    result = AceHelp::Client.execute(@mutation_query, feedback: {
      name: "Name-1",
      message: "Description about topic or general",
      article_id: article.id
    })
    assert_equal result.data.add_feedback.feedback.name, "Name-1"
  end

  test "create feedback without message" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@mutation_query, feedback: {
        name: "Name-2"
      })
    end
  end

  test "close feedback" do
    feedback = feedbacks(:ror_feedback)
    query = <<-GRAPHQL
              mutation($id: ID!)
                {
                  closeFeedback(input: {id: $id})
                  { feedback { id, status }
                    errors { path, message }
                  }
                }
            GRAPHQL
    result = AceHelp::Client.execute(query, id: feedback.id)
    assert_equal result.data.close_feedback.feedback.status, "closed"
  end
end
