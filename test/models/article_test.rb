# frozen_string_literal: true

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def test_article_validation
    article = articles :ror
    assert article.valid?
  end

  def setup
    Searchkick.enable_callbacks
  end

  def teardown
    Searchkick.disable_callbacks
  end

  def test_search
    c1 = Category.create! name: "Code", organization_id: Organization.first.id
    org = Organization.create! name: "Google", email: "google@google.com"
    Article.reindex
    c1.articles.create!(
      title: "How do I put nodejs code in my website?",
      desc: "coming soon",
      organization_id: org.id
    )

    Article.reindex

    assert_equal ["How do I put nodejs code in my website?"], Article.search("nodejs").map(&:title)
  end

  def test_search_using
    @article = articles :life
    @url = urls :bigbinary
    @organization = organizations :bigbinary
    Article.reindex
    @article.urls << @url
    @article.update(organization_id: @organization.id)
    Article.reindex
    assert_equal [@article], Article.search_using(@organization, article_id: @article.id, status: "offline", url: @url.url)
    assert_equal [@article], Article.search_using(@organization, article_id: @article.id, status: "offline", url: "")
    @article.online!
    assert_equal [@article], Article.search_using(@organization, article_id: "", status: "online", url: @url.url)
    assert_equal [@article], Article.search_using(@organization, article_id: "", status: "online", url: "")

    assert_equal [], Article.search_using(@organization, article_id: "fake_id", status: "online", url: @url.url)
    assert_equal [@article], Article.search_using(@organization, search_string: "day")
    assert_equal [], Article.search_using(@organization, search_string: "fake_string")
  end
end
