# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::ArticlesSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :google

    @article.organization = @organization
    @url.organization = @organization
    @article.save!
    @url.save
  end

  def find(args)
    Resolvers::ArticlesSearch.new.call(nil, args, organization: @organization)
  end

  test "show article failure" do
    assert_equal find(id: -1).size, 0
  end

  test "show article success" do
    assert_equal find(id: @article.id), [@article]
    assert_equal find(id: @article.id, url: "http://google.com"), []
    assert_equal find(url: @url.url_pattern).last, Article.joins(categories: :urls).where(urls: { url_pattern: "http://google.com" }).last
  end


  test "search articles success" do
    query = <<-'GRAPHQL'
              query {
                articles {
                  id
                  title
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query)

    assert_equal result.data.articles.size, 2
    assert_equal result.data.articles.last.title, @article.title
  end
end
