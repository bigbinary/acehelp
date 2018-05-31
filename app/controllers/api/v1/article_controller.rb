# frozen_string_literal: true

module Api
  module V1
    class ArticleController < BaseController
      before_action :load_article, only: :show

      def show
        render json: @article
      end

      def index
        if params[:url].present?
          url = Url.find_by!(url: params[:url])
        end

        if url.present?
          render json: url.articles, root: "articles"
        else
          render_bad_request "Bad request"
        end
      end

      def search
        render json: Article.search(params[:query], {
          fields: ["title^2", "desc"],
          limit: 10,
          load: false,
          operator: "or",
          select: [:id, :title, :desc],
          order: { _score: :desc }
        })
      end

      private
        def load_article
          @article = Article.find(params[:id])
        end
    end
  end
end
