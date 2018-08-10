# frozen_string_literal: true

class ArticleUrl < ApplicationRecord
  belongs_to :article
  belongs_to :url

  validates :article_id, uniqueness: { scope: [:url_id] }, presence: true
end
