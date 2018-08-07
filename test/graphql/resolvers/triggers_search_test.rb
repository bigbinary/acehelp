# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"


class Resolvers::TriggersSearchTest < ActiveSupport::TestCase
  setup do
    @triggers = triggers
    @graph_client = AceHelp::Client
  end

  def find
    Resolvers::TriggersSearch.new.call(nil, {}, { })
  end

  test "get_all_categories_success" do
    assert_equal find.pluck(:slug), ["auto_update_user", "auto_change_watch_list"]
  end

  test "resolver graphql test" do
    response = @graph_client.query <<-GRAPHq
      query {
        triggers {
          slug
        }
      }
    GRAPHq
    assert_empty (response.data.triggers.map(&:slug) - ["auto_update_user", "auto_change_watch_list"])
  end

end
