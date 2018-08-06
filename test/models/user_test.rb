# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:super_admin)
    @user = users(:brad)
  end

  test "test valid user" do
    assert @user.valid?
  end

  test "user is not valid is email is not present" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "user valid after adding organization" do
    args = { email: @user.email, name: "Organization test" }
    @user.add_organization(args.with_indifferent_access)
    assert @user.valid?
    assert_equal @user.organizations.last.name, args[:name]
  end
end
