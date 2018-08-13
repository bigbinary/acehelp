# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::UsersSearchTest < ActiveSupport::TestCase
  setup do
    @user = users :brad
    @organization = organizations :bigbinary
    @user.organizations << @organization
  end

  def find(args)
    Resolvers::UsersSearch.new.call(nil, args, organization: @organization)
  end

  test "get_all_users_success" do
    assert_equal [@user.email], find(Hash.new).pluck(:email)
  end
end
