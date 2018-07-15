# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
end
