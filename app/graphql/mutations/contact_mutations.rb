# frozen_string_literal: true

class Mutations::ContactMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateContact"

    input_field :name, !types.String
    input_field :email, !types.String
    input_field :message, !types.String

    return_field :contact, Types::ContactType

    resolve ->(object, inputs, context) {
      new_contact = Contact.new(name: inputs[:name], email: inputs[:email], message: inputs[:message])

      if new_contact.save
        { contact: new_contact }
      else
        raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(new_contact))
      end
    }
  end
end
