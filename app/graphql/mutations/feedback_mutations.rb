# frozen_string_literal: true

class Mutations::FeedbackMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateFeedback"

    input_field :name, types.String
    input_field :message, !types.String
    input_field :article_id, types.String

    return_field :feedback, Types::FeedbackType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {

      sanitized_params = inputs.to_h.slice(*inputs.keys)
      new_feedback = Feedback.new(sanitized_params)
      if new_feedback.save!
        feedback = new_feedback
      else
        errors = Utils::ErrorHandler.new.generate_detailed_error_hash(new_feedback, context)
      end

      {
        feedback: feedback,
        errors: errors
      }
    }
  end
end