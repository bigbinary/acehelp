class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.string :name
      t.text :message, null: false
      t.uuid :article_id, null: false
      t.timestamps
    end
    add_foreign_key :feedbacks, :articles
    add_index :feedbacks, :article_id
  end
end
