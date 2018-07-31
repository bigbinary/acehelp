# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories

  belongs_to :organization

  validates :name, presence: true

  scope :for_organization, ->(org) { where(organization: org) }
end
