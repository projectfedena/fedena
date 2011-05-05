class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.integer  :sender
      t.integer  :recipient
      t.string   :subject
      t.text   :body
      t.boolean  :is_read, :default=>false
      t.boolean  :is_deleted_by_sender, :default=>false
      t.boolean  :is_deleted_by_recipient, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
