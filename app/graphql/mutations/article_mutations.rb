# frozen_string_literal: true

class Mutations::ArticleMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateArticle"

    input_field :category_id, types.String
    input_field :title, !types.String
    input_field :desc, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_article = Article.new(title: inputs[:title], desc: inputs[:desc])

      if inputs[:category_id].present?
        category = Category.find_by!(id: inputs[:category_id])
        new_article.category = category
      end

      new_article.organization = context[:organization]

      if new_article.save
        article = new_article
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_article, context)
      end

      {
        article: article,
        errors: errors
      }
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name "UpdateArticle"

    input_field :id, !types.String

    ArticleInputObjectType = GraphQL::InputObjectType.define do
      name "ArticleInput"
      input_field :category_id, !types.String
      input_field :title, !types.String
      input_field :desc, !types.String
    end
    input_field :article, !ArticleInputObjectType

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article.nil?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      else
        if article.update_attributes(inputs[:article].to_h)
          updated_article = article
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end

        {
          article: updated_article,
          errors: errors
        }
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyArticle"

    input_field :id, !types.String

    return_field :deletedId, !types.String
    return_field :errors, types[Types::ErrorType]

    resolve ->(_obj, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article.blank?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      else
        if article.destroy
          deleted_id = inputs[:id]
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      end

      {
        deletedId: deleted_id,
        errors: errors
      }
    }
  end

  Upvote = GraphQL::Relay::Mutation.define do
    name "Upvote"

    input_field :id, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if article
        if article.increment_upvote
          upvoted_article = article
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      end
      {
        article: upvoted_article,
        errors: errors
      }
    }
  end

  Downvote = GraphQL::Relay::Mutation.define do
    name "Downvote"

    input_field :id, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article
        if article.increment_downvote
          downvoted_article = article
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      end

      {
        article: downvoted_article,
        errors: errors
      }
    }
  end
end
