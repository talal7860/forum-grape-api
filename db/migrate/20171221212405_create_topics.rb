class CreateTopics < ActiveRecord::Migration[5.1]
  def change
    create_table :topics do |t|
      t.string :title
      t.integer :added_by_id

      t.timestamps
    end
  end
end
