# frozen_string_literal: true

module Api
  module V1
    class TicketController < BaseController

      before_action :load_ticket, only: :show

      def show
        render json: @ticket
      end

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

        def load_ticket
          @ticket = Ticket.find(params[:id])
        end

    end
  end
end
