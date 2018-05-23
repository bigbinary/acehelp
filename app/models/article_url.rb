class ArticleUrl < ApplicationRecord
  belongs_to :article
  belongs_to :url
end
