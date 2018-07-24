class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.string :name
      t.text :message
      t.uuid :article_id, null: true

      t.timestamps
    end
  end
end
