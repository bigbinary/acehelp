# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  enum status: {
    online: "online",
    offline: "offline"
  }

  belongs_to :organization
  has_many :article_urls, dependent: :destroy
  has_many :urls, through: :article_urls

  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories

  enum status: {
    online: "online",
    offline: "offline"
  }

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
    if opts[:article_id].present? && opts[:url].present?
      articles.joins(:urls).where(
        "articles.id = ? AND
        urls.url = ?",
        opts[:article_id], opts[:url]
      ).for_organization(org)
    elsif opts[:article_id].present?
      articles.where(id: opts[:article_id]).for_organization(org)
    elsif opts[:url].present?
      articles.joins(:urls).where(
        "urls.url = ?", opts[:url]
      ).for_organization(org)
    elsif opts[:search_string].present?
      articles = Article.search opts[:search_string], where: { organization_id: org.id }
      articles.each_with_object([]) { |article, arr| arr.push(article) }
    else
      articles.for_organization(org)
    end
  end
end
