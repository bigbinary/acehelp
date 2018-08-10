# frozen_string_literal: true

class AutoCloseResolvedTicketsJob
  include Delayed::RecurringJob

  run_every 1.day
  run_at "12:00am"
  timezone "Asia/Kolkata"
  queue "default"

  def perform
    service = AutoCloseResolvedTicketService.new
    service.process
  end
end
