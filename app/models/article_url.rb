# frozen_string_literal: true

class ArticleUrl < ApplicationRecord
  belongs_to :article
  belongs_to :url
end
