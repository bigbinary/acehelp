# frozen_string_literal: true

class AutoCloseResolvedTicketsWorker
  include Sidekiq::Worker

  def perform
    service = AutoCloseResolvedTicketService.new
    service.process
    logger.info("Auto closed resolved tickets.")
  end
end
