# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  enum status: {
    active: "active",
    inactive: "inactive"
  }

  belongs_to :organization

  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories
  has_many_attached :attachments
  has_many :feedbacks, dependent: :destroy

  validates :title, uniqueness: { scope: [:organization_id] }, presence: true

  scope :for_organization, ->(org) { where(organization: org) }

  scope :persisted_articles, -> { where(temporary: false) }

  scope :search_with_id, ->(id) { id && where(id: id) }

  scope :search_with_status, ->(status) { status && where(status: status) }

  scope :temporary_articles, -> { where(temporary: true) }

  scope :search_with_url, ->(url) do
    url && joins(:urls).where(urls: { url: url })
  end

  scope :article_saved_two_hours_ago, -> do
    where("updated_at > ?", 2.hours.ago)
  end

  def increment_upvote
    self.update(upvotes_count: self.upvotes_count + 1)
  end

  def increment_downvote
    self.update(downvotes_count: self.downvotes_count + 1)
  end

  def self.search_using(organization, options = {})
    search = ArticleSearchService.new(organization, options)
    search.process
  end
end
