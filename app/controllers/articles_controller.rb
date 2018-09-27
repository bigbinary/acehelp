# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :ensure_user_is_logged_in
  include LoadOrganization
  before_action :article, only: :upload

  def index
    render
  end

  def upload
    @article.images.attach(article_params[:images])
  end

  private

    def article_params
      params.require(:article).permit(images: [])
    end

    def article
      @article = Article.find_by!(id: params[:id])
    end
end
