class CreateEmbeds < ActiveRecord::Migration
  def change
    create_table :embeds do |t|
      t.string :title
      t.text :description
      t.integer :message_id
      t.string :og_type
      t.string :url
      t.string :image

      t.timestamps null: false
    end
  end
end
