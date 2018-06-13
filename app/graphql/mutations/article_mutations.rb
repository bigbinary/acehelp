# frozen_string_literal: true

class Mutations::ArticleMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateArticle"

    input_field :category_id, !types.ID
    input_field :title, !types.String
    input_field :desc, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types.String

    resolve ->(object, inputs, context) {
      category = Category.find_by_id(inputs[:category_id])
      return { errors: "Category not found" } if category.nil?

      new_article = category.articles.build(title: inputs[:title], desc: inputs[:desc])
      new_article.organization = context[:organization]

      if new_article.save
        { article: new_article }
      else
        GraphQL::ExecutionError.new("Invalid input: #{new_article.errors.full_messages.join(', ')}")
      end
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name "UpdateArticle"

    ArticleInputObjectType = GraphQL::InputObjectType.define do
      name "ArticleInput"
      input_field :category_id, !types.ID
      input_field :title, !types.String
      input_field :desc, !types.String
    end
    input_field :id, !types.ID
    input_field :article, !ArticleInputObjectType

    return_field :article, Types::ArticleType
    return_field :errors, types.String

    resolve ->(object, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)
      return { errors: "Article not found" } if article.nil?

      if article.update_attributes(inputs[:article].to_h)
        { article: article }
      else
        GraphQL::ExecutionError.new("Invalid input: #{article.errors.full_messages.join(', ')}")
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyArticle"

    input_field :id, !types.ID

    return_field :deletedId, !types.ID
    return_field :errors, types.String

    resolve ->(_obj, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)
      return { errors: "Article not found" } if article.nil?

      article.destroy!

      { deletedId: inputs[:id] }
    }
  end
end
