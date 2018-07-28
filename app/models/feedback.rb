# frozen_string_literal: true
#
class Feedback < ApplicationRecord
  validates :message, presence: true
  belongs_to :article
end
