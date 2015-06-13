class AddCursorColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :cursor, :integer
  end
end
