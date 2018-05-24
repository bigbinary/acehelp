class Organization < ApplicationRecord
  has_many :urls
  has_many :articles

  validates :name, presence: true
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :api_key, :case_sensitive => false

  before_create :set_api_key

  private

  def set_api_key
    self.api_key = SecureRandom.hex
  end
end
