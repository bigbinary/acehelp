class Organization < ApplicationRecord
  include ModelApiKeyConcern

  has_many :urls
  has_many :articles

  validates :name, presence: true
  validates_uniqueness_of :name, :case_sensitive => false
end
