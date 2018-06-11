require 'test_helper'

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
end
