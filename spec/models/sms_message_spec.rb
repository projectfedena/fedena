require 'spec_helper'

describe SmsMessage do
  it { should have_many(:sms_logs) }

  describe '.get_sms_messages' do
    before do
      @sms_message = SmsMessage.create(:body => 'sms1')
    end

    it 'returns sms messages' do
      SmsMessage.get_sms_messages.should == [@sms_message]
    end
  end

  describe '#get_sms_logs' do
    before do
      @sms_message = SmsMessage.create(:body => 'sms1')
      @sms_logs    = SmsLog.create(:sms_message_id => @sms_message.id)
    end

    it 'returns sms logs' do
      @sms_message.get_sms_logs.should == [@sms_logs]
    end
  end
end