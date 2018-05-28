module Api::V1
  class CategoryController < BaseController

    def index
      categories = Category.all
      render json: categories, root: "categories"
    end

  end
end
