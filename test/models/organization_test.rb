require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def test_name_validation
    organization = organizations :bigbinary
    organization.api_key = nil
    assert organization.valid?

    organization.name = ""
    organization.save
    assert organization.errors.added?(:name, :blank)

    organization.name = nil
    organization.save
    assert organization.errors.added?(:name, :blank)
  end
end
