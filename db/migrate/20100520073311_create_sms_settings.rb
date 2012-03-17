class CreateSmsSettings < ActiveRecord::Migration
  def self.up
    create_table :sms_settings do |t|
      t.string :settings_key
      t.boolean :is_enabled, :default=>false
    end
  end

  def self.down
    drop_table :sms_settings
  end
end
