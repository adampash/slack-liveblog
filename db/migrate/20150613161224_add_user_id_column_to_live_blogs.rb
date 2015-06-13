class AddUserIdColumnToLiveBlogs < ActiveRecord::Migration
  def change
    add_column :live_blogs, :user_id, :integer
  end
end
