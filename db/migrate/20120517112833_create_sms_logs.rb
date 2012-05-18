class CreateSmsLogs < ActiveRecord::Migration
  def self.up
    create_table :sms_logs do |t|
      t.string   :mobile
      t.string   :gateway_response
      t.string   :sms_message_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sms_logs
  end
end
