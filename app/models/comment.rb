class Comment < ApplicationRecord

  belongs_to :agent
  belongs_to :ticket

end
