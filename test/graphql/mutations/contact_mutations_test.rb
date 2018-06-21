# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ContactMutationsTest < ActiveSupport::TestCase
  test "create contact mutations" do
    query = <<-'GRAPHQL'
              mutation($input: CreateContactInput!) {
                addContact(input: $input) {
                  contact {
                    id
                    name
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { name: "Contact_name", email: "contact@email.com", message: "Dummy" })

    assert_equal result.data.add_contact.contact.name, "Contact_name"
  end

  test "create contact mutations failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateContactInput!) {
                addContact(input: $input) {
                  contact {
                    id
                    name
                  }
                  errors {
                    message
                    path 
                  }
                }
              }
            GRAPHQL
    result = AceHelp::Client.execute(query, input: { name: "", email: "contact@email.com", message: "Dummy" })

    assert_nil result.data.add_contact.contact
  end

  test "create contact mutation error failute test" do
    query = <<-'GRAPHQL'
              mutation($input: CreateContactInput!) {
                addContact(input: $input) {
                  contact {
                    id
                  }
                  errors {
                    message
                    path 
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: { name: "", email: "contact@email.com", message: "Dummy" })
    assert_not_empty result.data.add_contact.errors.flat_map(&:path) & ['addContact', 'name']
  end

end
