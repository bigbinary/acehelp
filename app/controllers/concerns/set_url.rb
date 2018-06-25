#frozen_string_literal: true

module SetUrl
  extend ActiveSupport::Concern

  included do
    before_action :set_url
  end

  def set_url
    @url = Url.first
  end
end
