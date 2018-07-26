# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
  belongs_to :organization

  scope :for_organization, ->(org) { where(organization: org) }
end
