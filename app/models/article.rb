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

  scope :persisted_articles, -> { where(temporary: false) }

  scope :search_with_id, ->(id) { id && where(id: id) }

  scope :search_with_status, ->(status) { status && where(status: status) }

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
    articles = articles.search_with_url_pattern(articles, options[:url], org)
    if options[:search_string].present?
      articles = articles.search options[:search_string]
      articles = articles.each_with_object([]) { |article, arr| arr.push(article) }
    end
    articles
  end

  private

    def self.search_with_url_pattern(articles, incoming_url, org)
      return articles if incoming_url.nil?
      url_ids = urls_with_contains_rule(org, incoming_url) +
        urls_with_ends_with_rule(org, incoming_url) +
        urls_with_is_url_rule(org, incoming_url)
      if url_ids.any?
        articles = articles.joins(:urls).where(urls: { id: url_ids })
      else
        articles = []
      end
      articles
    end

    def self.urls_with_contains_rule(org, incoming_url)
      urls = org.urls.where(url_rule: :contains)
      url_ids = []
      urls.each do |url|
        url_ids << url.id if incoming_url.include? url.url_pattern
      end
      url_ids
    end

    def self.urls_with_ends_with_rule(org, incoming_url)
      urls = org.urls.where(url_rule: :ends_with)
      url_ids = []
      urls.each do |url|
        url_ids << url.id if incoming_url.match(Regexp.new url.url_pattern)
      end
      url_ids
    end

    def self.urls_with_is_url_rule(org, incoming_url)
      urls = org.urls.where(url_rule: :is)
      url_ids = []
      uri = URI.parse(incoming_url)
      urls.each do |url|
        url_ids << url.id if uri.is_a?(URI::HTTP)
      end
      url_ids
    end

  # def self.pattern_matching_with_postgres_query(articles, url, org)
  #   url_ids = Url.where("? ~* url_pattern", url).pluck(:id)
  #   if url_ids.any?
  #     articles = articles.joins(:urls).where(urls: { id: url_ids })
  #   else
  #     articles = []
  #   end
  #   articles
  # end
end
