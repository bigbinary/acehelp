# frozen_string_literal: true

class Contact < ApplicationRecord
  default_scope -> { order("created_at ASC") }
  validates :name, :email, :message, presence: true
end
