# frozen_string_literal: true

class CustomerMailer < ApplicationMailer
  def reply_to_ticket_email(ticket, comment)
    @customer_name = ticket.name
    @reply = comment.info

    mail(to: ticket.email, subject: "Respose to your support ticket")
  end
end
