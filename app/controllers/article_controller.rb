class ArticleController < ApplicationController

  before_action :load_organization, except: :index
  before_action :set_article, only: [:show, :update, :destroy]
  
  def index
    article_scope = if params[:url].present?
                      Url.find_by(url: params[:url])
                    elsif params[:api_key].present?
                      load_organization
                      @organization
                    end

    if article_scope.present?
      render json: article_scope.articles, root: "articles", status: 200
    else
      raise BadRequest.new "Invalid Request"
    end
  end

  def create
    raise BadRequest.new "Invalid category" unless valid_category_id?
    
    article = Article.new(article_params)
    article[:organization_id] = @organization.id

    if article.save
      render json: {message: "Article created successfully"}, status: 200
    else
      raise ActiveRecord::RecordNotSaved.new article.errors.full_messages
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
    @article = Article.find_by(id: params[:id], organization_id: @organization.id)
    raise ActiveRecord::RecordNotFound.new "Invalid Article" unless @article
  end

  def article_params
    params.require(:article).permit(:title, :desc, :category_id)
  end

  def valid_category_id?
    Category.exists?(id: article_params[:category_id])
  end

end
