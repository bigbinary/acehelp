class Trigger < ApplicationRecord

  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }


end
