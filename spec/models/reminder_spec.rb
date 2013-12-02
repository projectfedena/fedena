require 'spec_helper'

describe Reminder do
  it { should validate_presence_of(:body) }
  it { should belong_to(:user) }
  it { should belong_to(:to_user).class_name('User') }
end
