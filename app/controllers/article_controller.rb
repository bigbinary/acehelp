class ArticleController < ApplicationController

  before_action :set_article, only: [:show, :update, :destroy]
  
  def index
    article_scope = if params[:url].present?
                      Url.find_by(url: params[:url], organization_id: @organization.id)
                    else
                      @organization
                    end

    if article_scope.present?
      render json: article_scope.articles, root: "articles", status: 200
    else
      render_bad_request "Invalid Request"
    end
  end

  def create
    article = Article.new(article_params)
    article[:organization_id] = @organization.id

    if article.save
      render json: {message: "Article created successfully"}, status: 200
    else
      render_bad_request article.errors.full_messages.join(',')
    end
  end

  def update
    @article.update!(article_params)
    render json: {message: "Article updated successfully"}, status: 200
  end

  def destroy
    @article.destroy!
    render json: {message: "Article deleted successfully"}, status: 200
  end

  private

  def set_article
    @article = Article.find_by!(id: params[:id], organization_id: @organization.id)
  end

  def article_params
    params.require(:article).permit(:title, :desc, :category_id)
  end

end
