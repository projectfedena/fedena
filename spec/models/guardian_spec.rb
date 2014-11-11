require 'spec_helper'

describe Guardian do

  it { should belong_to(:country) }
  it { should belong_to(:ward).class_name('Student') }
  it { should belong_to(:user) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:relation) }
  it { should validate_presence_of(:ward_id) }
  it { should validate_format_of(:email).not_with('test@test').with_message(/must be a valid email address/) }

  context 'a exists record' do
    let(:guardian) { FactoryGirl.create(:guardian) }

    describe '#cant_be_a_future_date' do
      before { guardian.dob = Date.current + 1.day }

      context 'when dob > Date.current' do
        it 'is invalid' do
          guardian.should be_invalid
        end
      end
    end
  end

  describe '#immediate_contact?' do
    let(:guardian) { FactoryGirl.build(:guardian) }

    context 'ward.immediate_contact_id = id' do
      before do
        guardian.id = 5
        guardian.ward.immediate_contact_id = 5
      end

      it 'is true' do
        guardian.immediate_contact?.should be_true
      end
    end

    context 'ward.immediate_contact_id = id' do
      before do
        guardian.id = nil
        guardian.ward.immediate_contact_id = 5
      end

      it 'is false' do
        guardian.immediate_contact?.should be_false
      end
    end
  end

  describe '#full_name' do
    let(:guardian) { FactoryGirl.build(:guardian, :first_name => 'FN', :last_name => 'LN') }

    it 'returns full name' do
      guardian.full_name.should == 'FN LN'
    end
  end

  describe '#immediate_contact_nil' do
    let(:guardian) { FactoryGirl.build(:guardian) }

    context 'ward.immediate_contact_id = id' do
      before do
        guardian.id = 5
        guardian.ward.immediate_contact_id = 5
      end

      context 'when destroy guardian' do
        it 'does update ward.immediate_contact_id to nil' do
          guardian.destroy
          guardian.ward.immediate_contact_id.should be_nil
        end
      end
    end
  end

  describe '#archive_guardian' do
    let!(:guardian) { FactoryGirl.build(:guardian) }

    context 'ArchivedGuardian created' do
      context 'guardian.user present' do
        before do
          guardian.user = FactoryGirl.build(:admin_user, :is_deleted => false)
          guardian.archive_guardian(5)
        end

        it 'created ArchivedGuardian with ward_id = 5' do
          ArchivedGuardian.first.ward_id.should == 5
        end

        it 'does update user.is_deleted to true' do
          guardian.user.is_deleted.should be_true
        end

        it 'destroy guardian' do
          guardian.should be_destroyed
        end
      end
    end
  end

  describe '#create_guardian_user' do
    let(:guardian) { FactoryGirl.build(:guardian) }
    let(:student) { FactoryGirl.build(:student) }

    context 'when attributes are valid, user.save is true' do
      it 'does update user_id' do
        guardian.create_guardian_user(student)
        guardian.user_id.should_not be_nil
      end
    end
  end

  describe '#self.shift_user' do
    let(:student) { FactoryGirl.build(:student) }
    let(:user) { FactoryGirl.build(:admin_user) }
    let(:guardian) { FactoryGirl.build(:guardian) }

    context 'found guardian with student id' do
      before { Guardian.stub(:find_all_by_ward_id).and_return([guardian]) }

      context 'guardian has user and user.is_deleted is false' do
        before do
          user.is_deleted = false
          guardian.user = user
        end

        context 'immediate_contact is present' do
          before { student.stub(:immediate_contact).and_return(guardian) }

          it 'does create_guardian_user with student' do
            guardian.should_receive(:create_guardian_user)
            Guardian.shift_user(student)
          end

          it 'does update user.is_deleted to true' do
            Guardian.shift_user(student)
            user.should be_is_deleted
          end
        end
      end
    end
  end

end