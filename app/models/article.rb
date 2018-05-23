class Article < ApplicationRecord
  belongs_to :category
  has_many :article_urls
  has_many :urls, through: :article_urls
end
