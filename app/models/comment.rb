class Comment < ApplicationRecord

  belongs_to :commentable, polymorphic: true

  belongs_to :ticket

  def self.add_comment(args)
    commenter = Agent.find_by(id: args['user_id']) || User.find_by(id: args['user_id'])
    if commenter
      comment = commenter.comments.create!(ticket_id: args['ticket_id'], :info => args['info'])
      comment.ticket&.set_open! if commenter.is_a?(User)
      comment
    end
  end


end
