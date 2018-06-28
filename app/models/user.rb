# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true

  # Associations
  belongs_to :organization, autosave: true, dependent: :destroy, required: false

  def name
    "#{first_name} #{last_name}".squish
  end

  def add_organization(args)
    user = self
    user.create_organization(email: args["email"], name: args["name"])
  end
end
