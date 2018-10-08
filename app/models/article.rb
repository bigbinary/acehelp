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

  def increment_upvote
    self.update(upvotes_count: self.upvotes_count + 1)
  end

  def increment_downvote
    self.update(downvotes_count: self.downvotes_count + 1)
  end

  def self.search_using(org, options = {})
    articles = Article.persisted_articles.for_organization(org)
    articles = articles.search_with_status(
      options[:status]).search_with_id(options[:article_id])
    articles = articles.search_with_url(options[:url])
    if options[:search_string].present?
      articles = articles.search options[:search_string]
      articles = articles.each_with_object([]) { |article, arr| arr.push(article) }
    end
    articles
  end
end
