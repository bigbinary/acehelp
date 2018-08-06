# frozen_string_literal: true

class AutoCloseResolvedTicketService

  ALLOWED_MAX_DAYS_IN_RESOLVED = 4

  def process
    tickets = Ticket.all_resolved_before_n_days(ALLOWED_MAX_DAYS_IN_RESOLVED)
    tickets.map(&:close_ticket!)
  end

end
