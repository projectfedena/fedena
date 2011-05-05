class CreateSmsSettings < ActiveRecord::Migration
  def self.up
    create_table :sms_settings do |t|
      t.string :settings_key
      t.boolean :is_enabled, :default=>false
    end
    create_default
  end

  def self.down
    drop_table :sms_settings
  end

  def self.create_default
    SmsSetting.create :settings_key=>"ApplicationEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"ParentSmsEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"EmployeeSmsEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"StudentSmsEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"ResultPublishEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"StudentAdmissionEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"ExamScheduleResultEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"AttendanceEnabled",:is_enabled=>false
    SmsSetting.create :settings_key=>"NewsEventsEnabled",:is_enabled=>false
  end
end
