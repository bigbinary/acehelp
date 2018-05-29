# frozen_string_literal: true

module Api
  module V1
    class ArticleController < BaseController
      before_action :load_article, only: :show

      def show
        render json: @article
      end

      private
        def load_article
          @article = Article.find_by(id: params[:id])
          render_not_found "Invalid Article Id" if @article.blank?
        end
    end
  end
end
