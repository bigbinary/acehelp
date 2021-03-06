# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :urls, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :tickets, dependent: :destroy

  has_many :organization_users, dependent: :destroy
  has_many :users, through: :organization_users

  has_many :owners, class_name: "User"
  has_one :setting

  validates :name, presence: true
  validates :email, presence: true

  before_validation :ensure_api_key_assigned
  before_create :assign_slug
  after_create :create_setting

  private

    def ensure_api_key_assigned
      return if api_key.present?

      loop do
        self.api_key = SecureRandom.hex(10)
        break unless self.class.where(api_key: api_key).exists?
      end
    end

    def assign_slug
      existing_orgs_count = Organization.where("lower(name) = ?", name.downcase).count
      self.slug =
        if existing_orgs_count == 0
          name.parameterize.downcase
        else
          [name.parameterize.downcase, existing_orgs_count + 1].join("-")
        end
    end
end
