# frozen_string_literal: true

class ArticleSearchService
  attr_reader :organization, :options

  def initialize(organization, options = {})
    @organization = organization
    @options = options
  end

  def process
    articles = Article.persisted_articles.for_organization(organization)
    articles = articles.search_with_status(
      options[:status]).search_with_id(options[:article_id])
    articles = search_with_url_pattern(articles, options[:url], organization)
    if options[:search_string].present?
      articles = articles.search options[:search_string]
      articles = articles.each_with_object([]) { |article, arr| arr.push(article) }
    end
    articles
  end


  def search_with_url_pattern(articles, incoming_url, organization)
    return articles if incoming_url.nil?
    url_ids = urls_with_contains_rule(organization, incoming_url) +
      urls_with_ends_with_rule(organization, incoming_url) +
      urls_with_is_url_rule(organization, incoming_url)
    if url_ids.any?
      articles = articles.joins(categories: :urls).where(urls: { id: url_ids })
    else
      articles = []
    end
    articles
  end

  private

    def urls_with_contains_rule(organization, incoming_url)
      urls = organization.urls.where(url_rule: :contains)
      url_ids = []
      urls.each do |url|
        url_ids << url.id if incoming_url.include? url.url_pattern
      end
      url_ids
    end

    def urls_with_ends_with_rule(organization, incoming_url)
      urls = organization.urls.where(url_rule: :ends_with)
      url_ids = []
      urls.each do |url|
        url_ids << url.id if incoming_url.match(Regexp.new url.url_pattern)
      end
      url_ids
    end

    def urls_with_is_url_rule(organization, incoming_url)
      urls = organization.urls.where(url_rule: :is)
      url_ids = []
      urls.each do |url|
        url_ids << url.id if url.url_pattern == incoming_url
      end
      url_ids
    end
end
