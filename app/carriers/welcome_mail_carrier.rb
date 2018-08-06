# frozen_string_literal: true

class WelcomeMailCarrier

  attr_reader :sender, :receiver, :organization

  delegate :email, :name, :reset_password_token, to: :receiver, prefix: true
  delegate :email, :name, to: :sender, prefix: true

  def initialize(receiver_user_id, org_id, sender_user_id)
    @sender = User.find_by(id: sender_user_id)
    @receiver = User.find_by(id: receiver_user_id)
    @organization = Organization.find_by(id: org_id)
  end




end
