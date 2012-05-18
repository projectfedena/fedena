class AddSchoolIdToSmsMigration < ActiveRecord::Migration
  def self.up
    add_column  :sms_messages ,:school_id,:integer
    add_column  :sms_logs ,:school_id,:integer
  end

  def self.down
    remove_column  :sms_messages ,:school_id
    remove_column  :sms_logs ,:school_id
  end
end
