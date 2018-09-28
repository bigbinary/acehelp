# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  enum status: {
    active: "active",
    inactive: "inactive"
  }

  belongs_to :organization
  has_many :article_urls, dependent: :destroy
  has_many :urls, through: :article_urls

  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories
  has_many_attached :attachments

  validates :title, uniqueness: { scope: [:organization_id] }, presence: true

  scope :for_organization, ->(org) { where(organization: org) }

  def increment_upvote
    self.update(upvotes_count: self.upvotes_count + 1)
  end

  def increment_downvote
    self.update(downvotes_count: self.downvotes_count + 1)
  end

  def self.search_using(org, opts = {})
    articles = opts[:status].present? ? Article.send(opts[:status]) : Article.all
    articles = articles.for_organization(org)
    articles = articles.where(id: opts[:article_id]) if opts[:article_id].present?
    if opts[:url].present?
      articles = articles.joins(:urls).where(
        "urls.url = ?", opts[:url]
      )
    end
    if opts[:search_string].present?
      articles = articles.search opts[:search_string]
      articles = articles.each_with_object([]) { |article, arr| arr.push(article) }
    end
    articles
  end
end
