class ArticleController < ApplicationController
  include LoadOrganization

  before_action :load_article, only: [:show, :update, :destroy]
  
  def index
    article_scope = if params[:url].present?
                      Url.find_by(url: params[:url], organization_id: @organization.id)
                    else
                      @organization
                    end

    if article_scope.present?
      render json: article_scope.articles, root: 'articles'
    else
      render_bad_request 'Invalid Request'
    end
  end

  def create
    article = @organization.articles.new(article_params)

    if article.save
      render json: { message: 'Article created successfully' }
    else
      render_unprocessable_entity 'Bad Request'
    end
  end

  def update
    if @article.update(article_params)
      render json: { message: 'Article updated successfully' }
    else
      render_unprocessable_entity 'Bad Request'
    end
  end

  def destroy
    if @article.destroy
      render json: { message: 'Article deleted successfully' }
    else
      render_unprocessable_entity 'Bad Request'
    end
  end

  private

  def load_article
    @article = Article.find_by!(id: params[:id], organization_id: @organization.id)
  end

  def article_params
    params.require(:article).permit(:title, :desc, :category_id)
  end
end
