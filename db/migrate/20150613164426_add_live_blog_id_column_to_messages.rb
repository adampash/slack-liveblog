class AddLiveBlogIdColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :live_blog_id, :integer
  end
end
