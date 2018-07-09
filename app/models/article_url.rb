# frozen_string_literal: true

class ArticleUrl < ApplicationRecord
  default_scope -> { order("created_at ASC") }
  belongs_to :article
  belongs_to :url
end
