# frozen_string_literal: true
#
class Feedback < ApplicationRecord
  validates :message, presence: true


end
