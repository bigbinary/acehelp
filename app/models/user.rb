# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  belongs_to :organization, autosave: true, dependent: :destroy, required: false

  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notes, foreign_key: :agent_id

  scope :agents, -> { where(role: :agent) }

  scope :for_organization, ->(org) { joins(organization_users: :organization).where(organization_users: { organization_id: org.id }) }

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

  def deallocate_from_organization(organization_id)
    organization_users.where(organization_id: organization_id).destroy_all
  end

  def send_welcome_mail(sender_id:, org_id:)
    token = set_reset_password_token
    InviteUserMailer.welcome_email(self.id, org_id, sender_id, token).deliver_now
  end
  handle_asynchronously :send_welcome_mail, queue: 'devise'

end
