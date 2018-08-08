# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  acts_as_token_authenticatable

  belongs_to :organization, autosave: true, dependent: :destroy, required: false

  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users

  scope :agents, -> { where(role: :agent) }

  scope :for_organization, ->(org) { joins(organization_users: :organization) }

  def name
    ("#{first_name} #{last_name}".squish).presence || "Anonymous"
  end

  def name=(name)
    user = self
    user.first_name, user.last_name = name.split(/\s+/, 2) if name
  end


  def add_organization(args)
    user = self
    organization = Organization.create(email: args["email"], name: args["name"])
    user.organizations << organization
    organization
  end

  def assign_organization(org_data)
    user = self
    org_data = org_data if org_data.is_a?(Organization)
    user.organizations << org_data
    org_data
  end

  def deallocate_from_organization
    update_attributes(organization_id: nil)
  end

  def send_welcome_mail(sender_id:, org_id:)
    token = set_reset_password_token
    InviteUserMailer.welcome_email(self.id, org_id, sender_id, token).deliver_now
  end
  #handle_asynchronously :send_welcome_mail, queue: 'devise'

end
