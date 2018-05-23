class Url < ApplicationRecord
  has_many :article_urls
  has_many :articles, through: :article_urls

  validates_with HttpUrlValidator
end
