require "test_helper"

class TicketTest < ActiveSupport::TestCase
  def setup
    @ticket = tickets(:payment_issue_ticket)
  end

  test "valid ticket" do
    assert @ticket.valid?
  end

  test "ticket is not valid if message is not present" do
    @ticket.message = nil
    assert_not @ticket.valid?
  end

  test "auto update resolved_at - no action" do
    @ticket.status = Ticket.statuses[:open]
    @ticket.save
    assert_nil @ticket.resolved_at
  end

  test "auto update resolved_at - with action" do
    @ticket.status = Ticket.statuses[:resolved]
    @ticket.save
    assert_not_nil @ticket.resolved_at
  end

  test "AutoCloseResolvedTicketService test" do
    @ticket.update status: Ticket.statuses[:resolved]
    @ticket.update_columns resolved_at: 6.days.ago

    assert_not_nil @ticket.resolved_at
    assert_nil @ticket.closed_at

    AutoCloseResolvedTicketService.new.process

    @ticket.reload
    assert_nil @ticket.resolved_at
    assert_not_nil @ticket.closed_at
    assert_equal Ticket.statuses[:closed], @ticket.status
  end

end
