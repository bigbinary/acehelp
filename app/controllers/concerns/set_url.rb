# frozen_string_literal: true

# This is temporary, remove this concern once mapping between user and organization is created
module SetUrl
  extend ActiveSupport::Concern

  included do
    before_action :set_url
  end

  def set_url
    @url = Url.first
  end
end
