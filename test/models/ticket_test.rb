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
end
