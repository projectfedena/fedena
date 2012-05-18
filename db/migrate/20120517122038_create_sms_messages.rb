class CreateSmsMessages < ActiveRecord::Migration
  def self.up
    create_table :sms_messages do |t|
      t.string :body
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_messages
  end
end
