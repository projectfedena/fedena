require 'spec_helper'

describe ClassTiming do

  it { should have_many(:timetable_entries).dependent(:destroy) }
  it { should belong_to(:batch) }
  it { should validate_presence_of(:name) }

  context 'a record existed' do
    let!(:timing) { FactoryGirl.create(:class_timing) }

    it { should validate_uniqueness_of(:name).scoped_to(:batch_id, :is_deleted) }

    describe '#end_date_is_later_than_start_date' do
      it 'validates the end_date is later than start date' do
        timing.start_time = Time.new(2013,9,16,5,0,0)
        timing.end_time = Time.new(2013,9,16,3,0,0)
        timing.should be_invalid
      end
    end

    describe '#start_time_same_end_time?' do
      it 'validates start_time cannot be the same as end_time' do
        timing.start_time = Time.new(2013,9,16,5,0,0)
        timing.end_time = Time.new(2013,9,16,5,0,0)
        timing.should be_invalid
      end
    end
  end

  describe '.overlap' do
    let!(:timing) { FactoryGirl.create(:class_timing, :start_time => Time.current.change(hour: 5), :end_time => Time.current.change(hour: 10)) }

    describe '#check_start_overlap' do
      let(:timing1) { FactoryGirl.build(:class_timing, :start_time => Time.current.change(hour: 7), :end_time => Time.current.change(hour: 12)) }

      context 'when new record timing has timing1.start_time > start_time and timing.start_time < end_time of existing class timing ' do
        it { timing1.should be_invalid }
      end
    end

    describe '#check_between_overlap' do
      let(:timing1) { FactoryGirl.build(:class_timing, :start_time => Time.current.change(hour: 7), :end_time => Time.current.change(hour: 9)) }

      context 'when new record timing has end_time > start_time and timing.start_time < end_time of existing class timing ' do
        it { timing1.should be_invalid }
      end
    end

    describe '#check_end_overlap' do
      let(:timing1) { FactoryGirl.build(:class_timing, :start_time => Time.current.change(hour: 2), :end_time => Time.current.change(hour: 7)) }

      context 'when new record timing has end_time > start_time and timing.end_time < end_time of existing class timing ' do
        it { timing1.should be_invalid }
      end
    end
  end

  describe '.scope' do
    let!(:timing1) { FactoryGirl.create(:class_timing, :start_time => Time.current.change(hour: 5), :end_time => Time.current.change(hour: 11)) }
    let!(:timing2) { FactoryGirl.create(:class_timing, :start_time => Time.current.change(hour: 12), :end_time => Time.current.change(hour: 16)) }

    describe '#for_batch' do
      before do
        timing1.update_attributes(:batch_id => 55, :is_deleted => false, :is_break => false)
        timing2.update_attributes(:batch_id => 56, :is_deleted => true, :is_break => false)
      end

      it 'returns for_batch ClassTiming' do
        ClassTiming.for_batch(55).should == [timing1]
      end
    end

    describe '.default' do
      before do
        timing1.update_attributes(:batch_id => nil, :is_break => false, :is_deleted => false)
        timing2.update_attributes(:batch_id => nil, :is_break => true, :is_deleted => false)
      end

      it 'returns default ClassTiming' do
        ClassTiming.default.should == [timing1]
      end
    end

    describe '.active_for_batch' do
      before do
        timing1.update_attributes(:batch_id => 55, :is_deleted => true)
        timing2.update_attributes(:batch_id => 56, :is_deleted => false)
      end

      it 'returns active for batch ClassTiming' do
        ClassTiming.active_for_batch(56).should == [timing2]
      end
    end

    describe '.active' do
      before do
        timing1.update_attributes(:batch_id => nil, :is_deleted => false)
        timing2.update_attributes(:batch_id => nil, :is_deleted => true)
      end

      it 'returns active ClassTiming' do
        active_timing = ClassTiming.active
        active_timing.count.should == 1
        active_timing.should include(timing1)
      end
    end
  end

end
