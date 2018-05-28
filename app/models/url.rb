# frozen_string_literal: true

class Url < ApplicationRecord
  has_many :article_urls
  has_many :articles, through: :article_urls
  belongs_to :organization

  validates_uniqueness_of :url, case_sensitive: false
  validates_with HttpUrlValidator
end
