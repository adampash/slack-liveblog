class AddAttachmentAttachmentToMessages < ActiveRecord::Migration
  def self.up
    change_table :messages do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :messages, :attachment
  end
end
