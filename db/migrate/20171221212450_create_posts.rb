class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string :content
      t.integer :added_by_id
      t.integer :topic_id, index: true

      t.timestamps
    end
  end
end
