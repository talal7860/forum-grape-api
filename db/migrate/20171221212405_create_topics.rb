class CreateTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :topics do |t|
      t.string :title
      t.integer :added_by_id, index: true
      t.integer :forum_id, index: true

      t.timestamps
    end
  end
end
