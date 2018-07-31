# frozen_string_literal: true

require "test_helper"

class Resolvers::UrlsSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :bigbinary

    @article.organization = @organization
    @url.organization = @organization
    @article.save!
    @url.save!
  end

  def find(args)
    Resolvers::UrlsSearch.new.call(nil, args, organization: @organization)
  end

  test "get_all_urls_success" do
    assert_equal ["http://bigbinary.com"], find(Hash.new).pluck(:url)
  end

  test "show url success" do
    assert_equal ["http://bigbinary.com"], find(url: "http://bigbinary.com").pluck(:url)
  end

  test "show url failure" do
    assert_equal 0, find(url: "xyz").size
  end
end
