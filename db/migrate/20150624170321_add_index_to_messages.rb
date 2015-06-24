class AddIndexToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :cursor
  end
end
