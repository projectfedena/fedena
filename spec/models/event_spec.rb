require 'spec_helper'

describe Event do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }

  it { should belong_to(:origin) }
  it { should have_many(:batch_events).dependent(:destroy) }
  it { should have_many(:employee_department_events).dependent(:destroy) }
  it { should have_many(:user_events).dependent(:destroy) }

  describe '.holidays' do
    context 'holidays event is found' do
      let!(:holiday_event1) { FactoryGirl.create(:event, :is_holiday => true) }
      let!(:holiday_event2) { FactoryGirl.create(:event, :is_holiday => false) }

      it 'returns holiday event' do
        Event.holidays.should == [holiday_event1]
      end
    end

    context 'holidays event is not found' do
      let!(:non_holiday_event1) { FactoryGirl.create(:event, :is_holiday => true) }
      let!(:non_holiday_event2) { FactoryGirl.create(:event, :is_holiday => false) }

      it 'returns no holiday event' do
        Event.holidays.should_not == [non_holiday_event2]
      end
    end
  end

  describe '.exams' do
    context 'exam event is found' do
      let!(:exams_event1) { FactoryGirl.create(:event, :is_exam => true) }
      let!(:exams_event2) { FactoryGirl.create(:event, :is_exam => false) }

      it 'returns exam event' do
        Event.exams.should == [exams_event1]
      end
    end

    context 'exam event is not found' do
      let!(:non_exams_event1) { FactoryGirl.create(:event, :is_exam => false) }
      let!(:non_exams_event2) { FactoryGirl.create(:event, :is_exam => true) }

      it 'returns no exam event' do
        Event.exams.should_not == [non_exams_event1]
      end
    end
  end

  describe '#valid_date' do
    context 'end_date is before start_date' do
      let!(:event) { FactoryGirl.build(:event, 
        :start_date => Date.current, 
        :end_date   => Date.current - 2.days) 
      }

      it 'returns validate error' do
        event.should be_invalid
        event.errors[:end_time].should == 'can not be before the start time'
      end
    end
  end

  describe '#student_event?' do
    context 'student event is found through finance fee collection' do
      before do
        @batch           = FactoryGirl.create(:batch)
        @student         = FactoryGirl.create(:student, :batch => @batch)
        @finance_fee_co  = FactoryGirl.create(:finance_fee_collection, :batch => @batch)
        @event           = FactoryGirl.create(:event, :origin => @finance_fee_co)
        FactoryGirl.create(:finance_fee, :finance_fee_collection => @finance_fee_co, :student => @student)
      end

      it 'returns true' do
        @event.student_event?(@student).should be_true
      end
    end

    context 'student event is found through user events' do
      before do
        @event   = FactoryGirl.create(:event)
        @student = FactoryGirl.create(:student)
        FactoryGirl.create(:user_event, :event => @event, :user => @student.user)
      end

      it 'returns true' do
        @event.student_event?(@student).should be_true
      end
    end

    context 'student event is not found through finance fee collection' do
      before do
        @batch           = FactoryGirl.create(:batch)
        @student         = FactoryGirl.create(:student, :batch => @batch)
        @finance_fee_co  = FactoryGirl.create(:finance_fee_collection)
        @event           = FactoryGirl.create(:event, :origin => @finance_fee_co)
      end

      it 'returns false' do
        @event.student_event?(@student).should be_false
      end
    end

    context 'student event is not found through user events' do
      before do
        @event   = FactoryGirl.create(:event)
        @student = FactoryGirl.create(:student)
      end

      it 'returns false' do
        @event.student_event?(@student).should be_false
      end
    end
  end

  describe '#employee_event?' do
    context 'employee event is found' do
      before do
        @event         = FactoryGirl.create(:event)
        @employee_user = FactoryGirl.create(:employee_user)
        FactoryGirl.create(:user_event, :event => @event, :user => @employee_user)
      end

      it 'returns true' do
        @event.employee_event?(@employee_user).should be_true
      end
    end

    context 'employee event is not found' do
      before do
        @event          = FactoryGirl.create(:event)
        @employee_user  = FactoryGirl.create(:employee_user)
      end

      it 'returns false' do
        @event.employee_event?(@employee_user).should be_false
      end
    end
  end

  describe '#active_event?' do
    context 'active event is found' do
      context 'origin nil' do
        let!(:event) { FactoryGirl.create(:event) }

        it 'returns true' do
          event.active_event?.should be_true
        end
      end

      context 'origin not nil' do
        let(:finance_fee_co) { FactoryGirl.create(:finance_fee_collection) }
        let(:event)          { FactoryGirl.create(:event, :origin => finance_fee_co) }

        it 'returns true' do
          event.active_event?.should be_true
        end
      end
    end

    context 'active event is not found' do
      let(:finance_fee_co) { FactoryGirl.create(:finance_fee_collection, :is_deleted => true) }
      let(:event)          { FactoryGirl.create(:event, :origin => finance_fee_co) }

      it 'returns false' do
        event.active_event?.should be_false
      end
    end
  end

  describe '#dates' do
    let(:event) { FactoryGirl.create(:event, :start_date => 'Sat, 14 Sep 2013', :end_date => 'Sun, 15 Sep 2013') }

    it 'returns dates of event' do
      event.dates.should == ['Sat, 14 Sep 2013'.to_date, 'Sun, 15 Sep 2013'.to_date]
    end
  end

  describe '.a_holiday?' do
    context 'the day is a holiday' do
      before { FactoryGirl.create(:event, 
        :start_date => Date.current - 2.days,
        :end_date => Date.current + 7.days,
        :is_holiday => true)
      }

      it 'returns true' do
        Event.a_holiday?(Date.current).should be_true
      end
    end

    context 'the day is not a holiday' do
      before { FactoryGirl.create(:event, 
        :start_date => Date.current + 1.days,
        :end_date => Date.current + 7.days,
        :is_holiday => true)
      }

      it 'returns false' do
        Event.a_holiday?(Date.current).should be_false
      end
    end
  end
end