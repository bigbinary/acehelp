# frozen_string_literal: true

class Url < ApplicationRecord
  has_many :url_categories, dependent: :destroy
  has_many :categories, through: :url_categories

  belongs_to :organization

  enum url_rule: {
    contains: "contains",
    ends_with: "ends_with",
    is: "is"
  }

  validates :url_pattern, presence: true
  scope :for_organization, ->(org) { where(organization: org) }

  before_save :change_url_pattern

  def change_url_pattern_to_placeholder
    self.url_pattern = self.url_pattern.sub(/\\w\+/, "*")
  end

  private

    def change_url_pattern
      self.url_pattern = self.url_pattern.sub(/\*+/, '\\w+')
    end
end
