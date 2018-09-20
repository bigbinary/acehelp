# frozen_string_literal: true

class Category < ApplicationRecord
  enum status: {
    active: "active",
    inactive: "inactive"
  }

  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories

  belongs_to :organization

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false

  scope :for_organization, ->(org) { where(organization: org) }
end
