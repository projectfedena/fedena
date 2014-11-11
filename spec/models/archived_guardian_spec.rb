require 'spec_helper'

describe ArchivedGuardian do
  it { should belong_to(:country) }
  it { should belong_to(:ward).class_name('ArchivedStudent') }

  describe '#full_name' do
    let(:archived_guardian) { FactoryGirl.create(:archived_guardian,
      :first_name => 'ABC',
      :last_name  => '123') }

    it 'returns full_name' do
      archived_guardian.full_name.should == 'ABC 123'
    end
  end

  describe '#immediate_contact?' do
    context 'immediate contact' do
      before do
        @archived_student  = FactoryGirl.create(:archived_student)
        @archived_guardian = FactoryGirl.create(:archived_guardian, :ward => @archived_student)
        @archived_student.immediate_contact_id = @archived_guardian.id
      end

      it 'returns true' do
        @archived_guardian.immediate_contact?.should be_true
      end
    end

    context 'not immediate contact' do
      before do
        @archived_student  = FactoryGirl.create(:archived_student)
        @archived_guardian = FactoryGirl.create(:archived_guardian, :ward => @archived_student)
      end
      
      it 'returns false' do
        @archived_guardian.immediate_contact?.should be_false
      end
    end
  end
end