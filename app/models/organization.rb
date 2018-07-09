# frozen_string_literal: tru

class Organization < ApplicationRecord
  default_scope -> { order("created_at ASC") }
  has_many :urls
  has_many :articles

  has_one :owner, class_name: 'User', foreign_key: 'user_id'

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false

  before_validation :ensure_api_key_assigned

  private

    def ensure_api_key_assigned
      return if api_key.present?

      loop do
        self.api_key = SecureRandom.hex(10)
        break unless self.class.where(api_key: api_key).exists?
      end
    end
end
