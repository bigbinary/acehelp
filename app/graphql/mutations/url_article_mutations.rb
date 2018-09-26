# frozen_string_literal: true

class Mutations::UrlArticleMutations
  AddUrlToArticle = GraphQL::Relay::Mutation.define do
    name "AddUrlToArticle"

    input_field :url_id, !types.String
    input_field :article_id, !types.String

    return_field :article, Types::CategoryType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      url = Url.for_organization(context[:organization])
                         .where(id: inputs[:url_id]).first

      article = Article.for_organization(context[:organization])
                         .where(id: inputs[:article_id]).first

      if url.blank?
        errors = Utils::ErrorHandler.new.error("Url not found", context)
      elsif article.blank?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      elsif url.articles.where(id: inputs[:article_id]).first.present?
        errors = Utils::ErrorHandler.new.error("Record already exists", context)
      else
        article_url = ArticleUrl.create(url_id: url.id, article_id: article.id)
        if article_url.persisted?
          return { article: article, errors: nil }
        else
          errors = Utils::ErrorHandler.new.detailed_error(article_url, context)
        end
      end

      {
        article: nil,
        errors: errors
      }
    }
  end

  RemoveUrlFromArticle = GraphQL::Relay::Mutation.define do
    name "RemoveUrlFromArticle"

    input_field :url_id, !types.String
    input_field :article_id, !types.String

    return_field :article, Types::CategoryType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      record = ArticleUrl.for_organization(context[:organization])
                         .where(article_id: inputs[:article_id])
                         .where(url_id: inputs[:url_id])
                         .first

      if record.present?
        if record.destroy
          return { article: article, errors: nil }
        else
          errors = Utils::ErrorHandler.new.detailed_error(record, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Record does not exist", context)
      end

      {
        article: nil,
        errors: errors
      }
    }
  end
end
