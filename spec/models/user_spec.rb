require 'spec_helper'

describe User do
  context 'validation user' do
    before do
      @user1 = Factory.create(:admin_user, :is_deleted => false)
      @user2 = Factory.create(:admin_user, :is_deleted => true)
    end

    it { should validate_uniqueness_of(:username).scoped_to(:is_deleted) unless @user1.is_deleted }
    it { should ensure_length_of(:username).is_at_least(1).is_at_most(20) }
    it { should ensure_length_of(:password).is_at_least(4).is_at_most(40) }
    it { should validate_format_of(:username).not_with('+admin_').with_message('must contain only letters, numbers, hyphen, and  underscores') }
    it { should validate_format_of(:email).not_with('test@test').with_message(/must be a valid email address/) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:password) }
    it { should have_and_belong_to_many(:privileges) }
    it { should have_many(:user_events) }
    it { should have_many(:events).through(:user_events) }
    it { should have_one(:student_record).class_name("Student") }
    it { should have_one(:employee_record).class_name("Employee") }

    describe "scope_name test" do
      describe ".active" do
        it "return active user" do
          User.active.should == [@user1]
        end
      end

      describe ".inactive" do
        it "return inactive user" do
          User.inactive.should == [@user2]
        end
      end
    end
  end

  describe '#check_reminders' do
    before do
      @user = FactoryGirl.create(:employee_user)
      FactoryGirl.create(:reminder, :recipient => @user.id, :is_read => true)
      FactoryGirl.create(:reminder, :recipient => @user.id, :is_read => false)
    end

    it 'returns number of read reminders' do
      @user.check_reminders.should == 1
    end
  end
end
