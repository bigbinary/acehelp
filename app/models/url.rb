# frozen_string_literal: true

class Url < ApplicationRecord
  has_many :article_urls, dependent: :destroy
  has_many :articles, through: :article_urls
  belongs_to :organization

  enum url_rule: {
    contains: "contains",
    ends_with: "ends_with"
  }

  # validates_uniqueness_of :url, case_sensitive: false
  # validates_with HttpUrlValidator
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
