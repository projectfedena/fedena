class SmsMessage < ActiveRecord::Base
  has_many :sms_logs

  def self.get_sms_messages(page = 1)
    SmsMessage.paginate(:order=>"id DESC", :page => page, :per_page => 30)
  end

  def get_sms_logs(page = 1)
    self.sms_logs.paginate( :order=>"id DESC", :page => page, :per_page => 30)
  end
end
