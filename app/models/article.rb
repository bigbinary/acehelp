# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  belongs_to :category
  belongs_to :organization
  has_many :article_urls
  has_many :urls, through: :article_urls

  validates :title, uniqueness: { scope: [:organization_id, :category_id] }, presence: true

  scope :for_organization, ->(org) { where(organization: org) }
end
