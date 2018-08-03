# frozen_string_literal: true

class Mutations::PostCommentInTicketMutations

  Create = GraphQL::Relay::Mutation.define do
    name "PostComment"

    PostCommentTicketObjectType = GraphQL::InputObjectType.define do
      name "CommentInput"
      input_field :ticket_id, !types.String
      input_field :agent_id, !types.String
      input_field :info, !types.String
    end


    input_field :comment, !PostCommentTicketObjectType

    return_field :comment, Types::TicketCommentType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_comment = Comment.new(inputs[:comment].to_h)

      if new_comment.save
        comment = new_comment
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_category, context)
      end

      {
        comment: comment,
        errors: errors
      }
    }
  end
end
