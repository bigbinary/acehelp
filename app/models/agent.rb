# frozen_string_literal: true

class Agent < User

  default_scope { agents }

  has_many :tickets

  def comments
    Comment.where(commentable_id: self.id, commentable_type: self.class.name)
  end
end
