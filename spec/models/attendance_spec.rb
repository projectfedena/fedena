require 'spec_helper'

describe Attendance do
  it { should belong_to(:student) }
  it { should belong_to(:batch) }

  it { should validate_presence_of(:reason) }
  it { should validate_presence_of(:month_date) }
  it { should validate_presence_of(:batch_id) }
  it { should validate_presence_of(:student_id) }

  describe '.validates uniqueness of student_id' do
    let!(:attendance) { FactoryGirl.create(:attendance) }

    it { should validate_uniqueness_of(:student_id).scoped_to(:month_date).with_message('already marked as absent') }
  end

  describe '.by_month' do
    let!(:attendance) { FactoryGirl.create(:attendance) }

    it 'returns all attendance by_month' do
      Attendance.by_month(Date.current).should == [attendance]
    end
  end

  describe '.by_month_and_batch' do
    let!(:attendance) { FactoryGirl.create(:attendance) }

    it 'returns all attendance by_month_and_batch' do
      Attendance.by_month_and_batch(Date.current, attendance.batch_id).should == [attendance]
    end
  end

  describe '#student_current_batch' do
    context 'attendance is not marked for present batch' do
      let(:attendance) { FactoryGirl.build(:attendance, :batch_id => 123)}

      it 'validates attendance must is marked for present batch' do
        attendance.should be_invalid
      end
    end
  end

  describe '#valid_month_date' do
    context 'Attendance before the date of admission' do
      let(:attendance) { FactoryGirl.build(:attendance, :month_date => 2.days.ago) }

      it 'validates attendance month date' do
        attendance.should be_invalid
      end
    end
  end

  describe '#full_day?' do
    context 'forenoon and afternoon is true' do
      let(:attendance) { FactoryGirl.build(:attendance, :forenoon => true, :afternoon => true) }

      it 'returns true' do
        attendance.full_day?.should be_true
      end
    end

    context 'forenoon or afternoon is false' do
      let(:attendance) { FactoryGirl.build(:attendance, :forenoon => true, :afternoon => false) }

      it 'returns false' do
        attendance.full_day?.should be_false
      end
    end
  end

  describe '#half_day?' do
    context 'forenoon or afternoon is true' do
      let(:attendance) { FactoryGirl.build(:attendance, :afternoon => true) }

      it 'returns true' do
        attendance.half_day?.should be_true
      end
    end

    context 'forenoon and afternoon is false' do
      let(:attendance) { FactoryGirl.build(:attendance, :forenoon => false, :afternoon => false) }

      it 'returns false' do
        attendance.half_day?.should be_false
      end
    end
  end

end