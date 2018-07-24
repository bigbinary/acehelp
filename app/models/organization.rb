# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :urls
  has_many :articles
  has_many :categories

  has_many :owners, class_name: "User"

  validates :name, presence: true
  validates :email, presence: true
  validates_uniqueness_of :name, case_sensitive: false

  before_validation :ensure_api_key_assigned
  before_create :assign_slug

  private

    def ensure_api_key_assigned
      return if api_key.present?

      loop do
        self.api_key = SecureRandom.hex(10)
        break unless self.class.where(api_key: api_key).exists?
      end
    end

    def assign_slug
      # TODO put it in a loop in case the slug is taken
      self.slug = self.name.parameterize
    end
end
