# frozen_string_literal: true

class Resolvers::TemporaryArticleSearch < GraphQL::Function
  type Types::ArticleType

  def call(obj, args, context)
    article = Article.new(
      title: "title",
      desc: "desc",
      organization_id: context[:organization].id
    )
    article.save(validate: false)
    article
  end
end
