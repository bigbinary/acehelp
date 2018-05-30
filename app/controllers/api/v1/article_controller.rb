# frozen_string_literal: true

module Api
  module V1
    class ArticleController < BaseController
      before_action :load_article, only: :show

      def show
        render json: @article
      end

      def search
        render json: Article.search(params[:query], {
          fields: ["title^2", "desc"],
          limit: 10,
          load: false,
          match: :phrase,
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
