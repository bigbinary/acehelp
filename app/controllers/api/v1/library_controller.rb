module Api::V1
  class LibraryController < BaseController

    def all
      categories = Category.all
      render json: categories, root: "categories", status: 200
    end

  end
end

