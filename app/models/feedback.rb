# frozen_string_literal: true

class Feedback < ApplicationRecord
  enum status: { open: "open", closed: "closed" }

  validates :message, presence: true
  belongs_to :article

  scope :for_organization, ->(org) { joins(:article).where(articles: { organization_id: org.id }) }
end
