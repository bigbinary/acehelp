class Organization < ApplicationRecord
  has_many :urls
  has_many :articles

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
