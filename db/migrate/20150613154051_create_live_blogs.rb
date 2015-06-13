class CreateLiveBlogs < ActiveRecord::Migration
  def change
    create_table :live_blogs do |t|
      t.string :name
      t.string :description
      t.string :channel_id
      t.string :channel_name
      t.boolean :live

      t.timestamps null: false
    end
  end
end
