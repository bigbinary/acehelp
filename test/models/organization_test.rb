# frozen_string_literal: true

require "test_helper"

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

  def test_slug_valiation
    organization = Organization.create! name: "Hello World", email: "a@example.com"
    assert_equal "hello-world", organization.slug

    organization = Organization.create! name: "Hello World", email: "a@example.com"
    assert_equal "hello-world-2", organization.slug

    organization = Organization.create! name: "Hello World", email: "a@example.com"
    assert_equal "hello-world-3", organization.slug
  end
end
