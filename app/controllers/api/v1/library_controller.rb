module Api::V1
  class LibraryController < BaseController

    def all
      categories = Category.all
      if categories.present?
        render json: categories, root: "categories", status: 200
      else
        render_no_content "No record found"
      end
    end

  end
end

