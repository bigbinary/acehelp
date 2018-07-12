# frozen_string_literal: true

module Api
  module V1
    class TicketsController < BaseController
      def create
        ticket = Ticket.new(ticket_params)

        if contact.save
          render json: { message: "Support ticket has been created. Someone will get back to you soon. Thanks." }
        else
          render_unprocessable_entity contact.errors.full_messages.to_sentence
        end
      end

      private

        def ticket_params
          params.require(:ticket).permit(:name, :email, :message)
        end
    end
  end
end
