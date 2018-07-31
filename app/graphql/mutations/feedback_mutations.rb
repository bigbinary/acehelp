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
      if new_feedback.save
        feedback = new_feedback
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_feedback, context)
      end

      {
        feedback: feedback,
        errors: errors
      }
    }
  end

  Close = GraphQL::Relay::Mutation.define do
    name "UpdateFeedbackStatus"
    input_field :id, !types.ID

    return_field :feedback, Types::FeedbackType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      feedback = Feedback.find_by(
        id: inputs[:id]
      )
      if feedback.nil?
        errors = Utils::ErrorHandler.new.error("Record Not Found", context)
      else
        if feedback.closed!
          updated_feedback = feedback
        else
          errors = Utils::ErrorHandler.new.detailed_error(feedback, context)
        end
      end

      {
        feedback: updated_feedback,
        errors: errors
      }

    }
  end
end
