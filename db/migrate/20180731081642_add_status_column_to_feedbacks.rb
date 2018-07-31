class AddStatusColumnToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :status, :string, default: :open, nil: false
  end
end
