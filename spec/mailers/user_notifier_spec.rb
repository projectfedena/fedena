require 'spec_helper'

describe UserNotifier do
  describe 'forgot_password' do
    before do
      @admin = Factory.create(:admin_user, :username => 'admin')
      @user = Factory.create(:employee_user, :reset_password_code => 'CODE65CODE')
      @mail = UserNotifier.deliver_forgot_password(@user, 'http://0.0.0.0:3000')
    end

    it 'renders the subject' do
      @mail.subject.should == ' Reset Password'
    end

    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it 'renders the sender email' do
      @mail.from.should == [@admin.email]
    end

    it 'assigns @name' do
      @mail.body.should match(@user.full_name)
    end

    it 'assigns @confirmation_url' do
      @mail.body.should match("http://0.0.0.0:3000/user/reset_password/#{@user.reset_password_code}")
    end
  end
end