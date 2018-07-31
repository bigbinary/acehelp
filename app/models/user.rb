# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_token_authenticatable

  validates :first_name, presence: true

  belongs_to :organization, autosave: true, dependent: :destroy, required: false

  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users

  def name
    "#{first_name} #{last_name}".squish
  end

  def name=(name)
    user = self
    user.first_name, user.last_name = name.split(/\s+/, 2)
  end

  def extract_firstname_from_email
    email.split('@').first
  end

  def add_organization(args)
    user = self
    user.organization = Organization.new(email: args["email"], name: args["name"])
    user.save
    user.organization
  end

  def assign_organization(org_data)
    user = self
    org_data = org_data.id if org_data.is_a?(Organization)
    user.organization_id = org_data
    user.save
  end

end
