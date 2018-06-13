# frozen_string_literal: true

require "test_helper"

class Resolvers::UrlsSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :bigbinary

    @article.category = @category
    @article.organization = @organization
    @url.organization = @organization
    @article.save
    @url.save
  end

  def find(args)
    Resolvers::UrlsSearch.new.call(nil, args, organization: @organization)
  end

  test "get_all_urls_success" do
    assert_equal find(Hash.new).pluck(:url), ["http://bigbinary.com"]
  end

  test "show url success" do
    assert_equal find(url: "http://bigbinary.com").pluck(:url), ["http://bigbinary.com"]
  end

  test "show url failure" do
    assert_equal find(url: "").size, 0
  end
end
