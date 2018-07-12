# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :name, :email, :message, presence: true
end
