# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  belongs_to :category
  belongs_to :organization
  has_many :article_urls
  has_many :urls, through: :article_urls

  validates :title, uniqueness: { scope: [:organization_id, :category_id] }, presence: true

  scope :for_organization, ->(org) { where(organization: org) }

  def increment_upvote
    self.update(upvotes_count: self.upvotes_count + 1)
  end

  def increment_downvote
    self.update(downvotes_count: self.downvotes_count + 1)
  end

end
