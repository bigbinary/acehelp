# frozen_string_literal: true

class UrlCategory < ApplicationRecord
  belongs_to :category
  belongs_to :url

  validates :category_id, uniqueness: { scope: [:url_id] }, presence: true
end
