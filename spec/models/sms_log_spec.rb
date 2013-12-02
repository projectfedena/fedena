require 'spec_helper'

describe SmsLog do

  it { should belong_to(:sms_message) }

end