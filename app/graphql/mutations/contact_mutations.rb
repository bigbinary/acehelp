# frozen_string_literal: true

class Mutations::ContactMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateContact"

    input_field :name, !types.String
    input_field :email, !types.String
    input_field :message, !types.String

    return_field :contact, Types::ContactType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_contact = Contact.new(name: inputs[:name], email: inputs[:email], message: inputs[:message])

      if new_contact.save
        contact = new_contact
      else
        errors = Utils::ErrorHandler.generate_detailed_error_hash(new_contact, context)
      end

      {
        contact: contact,
        errors: errors
      }
    }
  end
end
