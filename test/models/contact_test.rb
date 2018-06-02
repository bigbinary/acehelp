# frozen_string_literal: true

require "test_helper"

class ContactTest < ActiveSupport::TestCase
  def test_create_validation
    contact = contacts :otp_issue
    assert contact.valid?

    contact.name = ""
    contact.save
    assert contact.errors.added?(:name, :blank)

    contact.email = ""
    contact.save
    assert contact.errors.added?(:email, :blank)

    contact.message = ""
    contact.save
    assert contact.errors.added?(:message, :blank)
  end
end
