# frozen_string_literal: true

class InviteUserMailer < ApplicationMailer
  def welcome_email(receiver_user_id, org_id, sender_user_id, token)
    @token = token
    @email_carrier = WelcomeMailCarrier.new(receiver_user_id, org_id, sender_user_id)

    mail(to:   @email_carrier.receiver_email,
         subject: "Someone invited you to AceInvoice")
  end
end
