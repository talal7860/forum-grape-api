class CreateForums < ActiveRecord::Migration[5.1]
  def change
    create_table :forums do |t|
      t.string :title
      t.text :description
      t.integer :added_by_id

      t.timestamps
    end
  end
end
