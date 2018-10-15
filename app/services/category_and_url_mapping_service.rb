# frozen_string_literal: true

class CategoryAndUrlMappingService
  attr_reader :url_id, :category_ids, :organization
  attr_accessor :errors, :updated_url, :url

  def initialize(url_id, category_ids, organization)
    @url_id = url_id
    @category_ids = category_ids
    @organization = organization
    @errors = []
  end

  def process
    @url = Url.find_by(id: url_id, organization_id: organization.id)
    if url.nil?
      @errors = Utils::ErrorHandler.new.error("Url not found", context)
    else
      assign_categories
    end
    { updated_url: updated_url, errors: errors }
  end

  private

    def url_categories_assignment
      if category_ids.empty?
        remove_categories
      else
        assign_categories
      end
    end

    def remove_categories
      url.url_categories.delete_all
    end

    def assign_categories
      remove_categories
      categories = Category.where(id: category_ids)
      url.categories << categories
      @updated_url = url
    end
end
