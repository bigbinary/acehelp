# frozen_string_literal: true

class Resolvers::FeedbacksSearch < GraphQL::Function
  type !types[Types::FeedbackType]

  argument :status, types.String
  argument :article_id, types.ID

  def call(obj, args, context)
    query = Feedback.for_organization(
      context[:organization]
    ).where(
      status: args[:status]
    )

    article_id = args[:article_id]
    article_id.present? ? query.where(article_id: article_id) : query
  end
end
