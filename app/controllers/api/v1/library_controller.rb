module Api::V1
  class LibraryController < BaseController

    def all
      categories = Category.all
      if categories.present?
        render json: categories, root: "categories", status: 200
      else
        raise ActiveRecord::RecordNotFound.new "No record found"
      end
    end

  end
end

