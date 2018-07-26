# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :articles
  belongs_to :organization

  validates :name, presence: true

  scope :for_organization, ->(org) { where(organization: org) }
end
