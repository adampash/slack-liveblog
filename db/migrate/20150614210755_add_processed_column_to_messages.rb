class AddProcessedColumnToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :processed, :boolean, default: true
  end
end
