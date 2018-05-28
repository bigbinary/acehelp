# frozen_string_literal: true

module Api
  module V1
    class CategoryController < BaseController
      def index
        categories = Category.all
        render json: categories, root: "categories"
      end
    end
  end
end
