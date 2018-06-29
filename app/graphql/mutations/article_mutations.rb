# frozen_string_literal: true

class Mutations::ArticleMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateArticle"

    input_field :category_id, !types.ID
    input_field :title, !types.String
    input_field :desc, !types.String

    return_field :article, Types::ArticleType

    resolve ->(object, inputs, context) {
      category = Category.find_by_id(inputs[:category_id])
      if category.nil?
        raise GraphQL::ExecutionError.new("Category not found")
      else
        new_article = category.articles.new(title: inputs[:title], desc: inputs[:desc])
        new_article.organization = context[:organization]

        if new_article.save
          { article: new_article }
        else
          raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(new_article))
        end
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

    resolve ->(object, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if article.nil?
        raise GraphQL::ExecutionError.new("Article not found")
      else
        if article.update_attributes(inputs[:article].to_h)
          { article: article }
        else
          raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(article))
        end
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyArticle"

    input_field :id, !types.ID

    return_field :deletedId, types.ID

    resolve ->(_obj, inputs, context) {
      article = Article.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if !article
        raise GraphQL::ExecutionError.new("Article not found")
      else
        if article.destroy
          { deletedId: inputs[:id] }
        else
          raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(article))
        end
      end
    }
  end
end
