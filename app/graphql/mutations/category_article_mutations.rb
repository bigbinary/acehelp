# frozen_string_literal: true

class Mutations::CategoryArticleMutations
  Create = GraphQL::Relay::Mutation.define do
    name "AddCategoryToArticle"

    input_field :category_id, !types.String
    input_field :article_id, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      category = Category.for_organization(context[:organization])
                         .where(id: inputs[:category_id]).first

      article = Article.for_organization(context[:organization])
                         .where(id: inputs[:article_id]).first

      if category.blank?
        errors = Utils::ErrorHandler.new.error("Category not found", context)
      elsif article.blank?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      elsif category.articles.where(id: inputs[:article_id]).first.present?
        errors = Utils::ErrorHandler.new.error("Record already exists", context)
      else
        if article.update(category: category)
          updated_article = article
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      end

      {
        article: updated_article,
        errors: errors
      }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "RemoveCategoryFromArticle"

    input_field :category_id, !types.String
    input_field :article_id, !types.String

    return_field :article, Types::ArticleType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      category = Category.for_organization(context[:organization])
                         .where(id: inputs[:category_id]).first

      article = Article.for_organization(context[:organization])
                         .where(id: inputs[:article_id]).first

      if category.blank?
        errors = Utils::ErrorHandler.new.error("Category not found", context)
      elsif article.blank?
        errors = Utils::ErrorHandler.new.error("Article not found", context)
      elsif category.articles.where(id: inputs[:article_id]).exists?
        if article.update(category: nil)
          updated_article = article
        else
          errors = Utils::ErrorHandler.new.detailed_error(article, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Article does not have categeory", context)
      end

      {
        article: updated_article,
        errors: errors
      }
    }
  end
end
