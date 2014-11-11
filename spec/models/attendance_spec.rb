require 'spec_helper'

describe Attendance do
  it { should belong_to(:student) }
  it { should belong_to(:batch) }

  it { should validate_presence_of(:reason) }
  it { should validate_presence_of(:month_date) }
  it { should validate_presence_of(:batch_id) }
  it { should validate_presence_of(:student_id) }

  describe '.validates_uniqueness_of(:student_id)' do
    let!(:attendance) { FactoryGirl.create(:attendance) }

    it { should validate_uniqueness_of(:student_id).scoped_to(:month_date).with_message('already marked as absent') }
  end

  describe '.by_month' do
    let!(:batch) { FactoryGirl.create(:batch) }
    let!(:student) { FactoryGirl.create(:student,
      :batch          => batch,
      :admission_date => Date.current - 12.months)
    }
    let!(:attendance1) { FactoryGirl.create(:attendance,
      :student    => student,
      :batch      => batch,
      :month_date => Date.current - 2.months)
    }
    let!(:attendance2) { FactoryGirl.create(:attendance,
      :student    => student,
      :batch      => batch,
      :month_date => Date.current)
    }

    it 'returns all attendance by month' do
      Attendance.by_month(Date.current).should == [attendance2]
    end
  end

  describe '.by_month_and_batch' do
    let!(:batch) { FactoryGirl.create(:batch) }
    let!(:student) { FactoryGirl.create(:student,
      :batch          => batch,
      :admission_date => Date.current - 12.months)
    }
    let!(:attendance1) { FactoryGirl.create(:attendance,
      :student    => student,
      :batch      => batch,
      :month_date => Date.current.beginning_of_month)
    }
    let!(:attendance2) { FactoryGirl.create(:attendance,
      :student    => student,
      :batch      => batch,
      :month_date => Date.current - 2.months)
    }

    it 'returns all attendance by_month_and_batch' do
      Attendance.by_month_and_batch(Date.current, batch.id).should == [attendance1]
    end
  end

  describe '#student_current_batch' do
    context 'attendance is not marked for present batch' do
      let(:student)    { FactoryGirl.create(:student, :batch => FactoryGirl.create(:batch)) }
      let(:attendance) { FactoryGirl.build(:attendance, :student => student, :batch => FactoryGirl.create(:batch)) }

      it 'validates attendance must is marked for present batch' do
        attendance.should be_invalid
        attendance.errors['batch_id'].should == "attendance is not marked for present batch"
      end
    end
  end

  describe '#valid_month_date' do
    context 'Attendance before the date of admission' do
      let(:student)    { FactoryGirl.create(:student, :admission_date => Date.current) }
      let(:attendance) { FactoryGirl.build(:attendance, :student => student, :month_date => Date.current - 2.days) }

      it 'validates attendance month date' do
        attendance.should be_invalid
        attendance.errors['month_date'].should == "#{I18n.t('attendance_before_the_date_of_admission')}"
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