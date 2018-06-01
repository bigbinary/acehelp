# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      def test_create_success
        post api_v1_contacts_url, params: { contact: { name: "Piyush", email: "piyush@bigbinary.com", message: "Didn't get the otp" } }

        assert_response :success
      end

      def test_create_failure
        post api_v1_contacts_url, params: { contact: { name: "", email: "piyush@bigbinary.com", message: "Didn't get the otp" } }

        assert_response :unprocessable_entity
        post api_v1_contacts_url, params: { contact: { name: "Piyush", email: "", message: "Didn't get the otp" } }

        assert_response :unprocessable_entity
        post api_v1_contacts_url, params: { contact: { name: "Piyush", email: "piyush@bigbinary.com", message: "" } }

        assert_response :unprocessable_entity
      end
    end
  end
end
