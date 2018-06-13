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
                }
              }
            GRAPHQL

    assert_raises(Graphlient::Errors::ExecutionError) do
      AceHelp::Client.execute(query, input: { name: "", email: "contact@email.com", message: "Dummy" })
    end
  end
end
