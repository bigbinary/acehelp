# frozen_string_literal: true

class Mutations::ArticleMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateArticle"

    input_field :category_ids, types[types.String]
    input_field :url_ids, types[types.String]
    input_field :title, !types.String
    input_field :desc, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_article = Article.new(
        title: inputs[:title],
        desc: inputs[:desc],
        organization_id: context[:organization].id
      )

      if new_article.save
        if inputs[:category_ids].present?
          valid_category_ids = Category.where(id: inputs[:category_ids]).pluck(:id)
          new_article.category_ids = valid_category_ids
        end
        if inputs[:url_ids].present?
          valid_url_ids = Url.where(id: inputs[:url_ids]).pluck(:id)
          new_article.url_ids = valid_url_ids
        end
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
    input_field :category_ids, types[types.String]
    input_field :url_ids, types[types.String]
    input_field :title, !types.String
    input_field :desc, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article.nil?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      else
        if article.update_attributes(title: inputs[:title], desc: inputs[:desc], temporary: false)
          if inputs[:category_ids].present?
            article.category_ids = inputs[:category_ids]
          end
          if inputs[:url_ids].present?
            article.url_ids = inputs[:url_ids]
          end
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
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
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

  UpdateStatus = GraphQL::Relay::Mutation.define do
    name "UpdateStatus"

    input_field :id, !types.String
    input_field :status, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article
        if article.update_attributes(status: inputs[:status].downcase)
          new_article = article
          article.categories.update_all(status: :active) if article.active?
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      end

      {
        article: new_article,
        errors: errors
      }
    }
  end
end
