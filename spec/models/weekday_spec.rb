require 'spec_helper'

describe Weekday do
  it { should belong_to(:batch) }
  it { should have_many(:timetable_entries).dependent(:destroy) }

  describe 'scopes' do
    before do
      @batch = Factory.create(:batch)
      @w1 = Factory.create(:weekday,
        :weekday    => '1',
        :batch_id   => @batch.id,
        :is_deleted => false)
      @w2 = Factory.create(:weekday,
        :weekday    => '1',
        :batch_id   => nil,
        :is_deleted => false)
    end

    describe '.default' do
      it 'returns days sorted by ascending weekday' do
        Weekday.all.should == [@w1, @w2]
      end
    end

    describe '.default' do
      it 'returns days that are active and not belongs to any batch' do
        Weekday.default.should == [@w2]
      end
    end

    describe '.for_batch' do
      it 'returns days that are active and belongs to batch' do
        Weekday.for_batch(@batch.id).should == [@w1]
      end
    end
  end

  describe '#deactivate' do
    before do
      @w = Factory.create(:weekday, :is_deleted => false)
    end

    it 'sets is_deleted true' do
      @w.deactivate
      @w.should be_is_deleted
    end
  end

  describe '.weekday_by_day' do
    context 'no weekday found matching batch_id' do
      before do
        @w1 = Factory.create(:weekday,
          :batch_id    => nil,
          :day_of_week => 1,
          :weekday     => '1')
        @w2 = Factory.create(:weekday,
          :batch_id    => nil,
          :day_of_week => 1,
          :weekday     => '2')
      end

      it 'returns days group by day_of_week' do
        Weekday.weekday_by_day(555).should == { 1 => [@w1, @w2] }
      end
    end

    context 'weekday matching batch_id' do
      before do
        @w1 = Factory.create(:weekday,
          :batch_id    => 1,
          :day_of_week => 1,
          :weekday     => '1')
        @w2 = Factory.create(:weekday,
          :batch_id    => 1,
          :day_of_week => 1,
          :weekday     => '2')
        @w3 = Factory.create(:weekday, :batch_id => nil)
      end

      it 'returns days group by day_of_week' do
        Weekday.weekday_by_day(1).should == { 1 => [@w1, @w2] }
      end
    end
  end

  describe '.add_day' do
    context 'batch_id is 0' do
      context 'existing day' do
        before do
          @w1 = Factory.create(:weekday,
            :batch_id    => nil,
            :day_of_week => 1,
            :is_deleted  => true)
        end

        it 'updates existing day' do
          Weekday.add_day(0, 1)
          @w1.reload
          @w1.is_deleted.should be_false
          @w1.day_of_week.should == 1
        end
      end

      context 'no existing day' do
        it 'updates existing day' do
          lambda { Weekday.add_day(0, 1) }.should change(Weekday, :count).by(1)
          w1 = Weekday.last
          w1.day_of_week.should == 1
          w1.weekday.should == '1'
          w1.is_deleted.should be_false
          w1.batch_id.should be_nil
        end
      end
    end

    context 'batch_id is different to 0' do
      before { @batch = Factory.create(:batch) }

      context 'existing day' do
        before do
          @w1 = Factory.create(:weekday,
            :batch_id    => @batch.id,
            :day_of_week => 1,
            :is_deleted  => true)
        end

        it 'updates existing day' do
          Weekday.add_day(@batch.id, 1)
          @w1.reload
          @w1.is_deleted.should be_false
          @w1.day_of_week.should == 1
        end
      end

      context 'no existing day' do
        it 'updates existing day' do
          lambda { Weekday.add_day(@batch.id, 1) }.should change(Weekday, :count).by(1)
          w1 = Weekday.last
          w1.day_of_week.should == 1
          w1.weekday.should == '1'
          w1.is_deleted.should be_false
          w1.batch_id.should == @batch.id
        end
      end
    end
  end
end