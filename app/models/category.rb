# frozen_string_literal: true

class Category < ApplicationRecord
  default_scope -> { order("created_at ASC") }
  has_many :articles

  validates :name, presence: true
end
