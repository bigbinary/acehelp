# frozen_string_literal: true

module Api
  module V1
    class ContactsController < BaseController
      def create
        contact = Contact.new(contact_params)

        if contact.save
          render json: { message: "Thank you for your message. We will contact you soon!" }
        else
          render_unprocessable_entity contact.errors.full_messages.to_sentence
        end
      end

      private

        def contact_params
          params.require(:contact).permit(:name, :email, :message)
        end
    end
  end
end
