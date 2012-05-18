class SmsMessage < ActiveRecord::Base
  has_many :sms_logs
end
