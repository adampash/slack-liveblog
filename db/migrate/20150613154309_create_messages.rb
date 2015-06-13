class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.integer :user_id
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
