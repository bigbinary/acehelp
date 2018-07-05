# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true

  belongs_to :organization, autosave: true, dependent: :destroy, required: false

  def name
    "#{first_name} #{last_name}".squish
  end

  def add_organization(args)
    user = self
    user.organization = Organization.new(email: args["email"], name: args["name"])
    user.save
    user.organization
  end
end
