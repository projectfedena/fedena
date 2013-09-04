require 'spec_helper'

describe Course do
  context 'validate course' do
    before do
      @course1 = Factory.create(:course, :is_deleted => false)
      @course2 = Factory.create(:course, :is_deleted => true)
    end

    it { should validate_presence_of(:course_name) }
    it { should validate_presence_of(:code) }
    it { should have_many(:batches) }
    it { should have_many(:batch_groups) }
    it { should have_many(:ranking_levels) }
    it { should have_many(:class_designations) }
    it { should have_many(:subject_amounts) }
    it { should have_and_belong_to_many(:observation_groups) }

    it 'should at latest have a batch' do
      @course1.batches.count.should >= 1
    end

    describe '#inactivate' do
      it 'sets is_deleted true' do
        @course1.inactivate
        @course1.should be_is_deleted
      end
    end

    describe "scope_name test" do
      describe ".active" do
        it "returns active course" do
          Course.active.should == [@course1]
        end
      end

      describe ".deleted" do
        it "returns deleted course" do
          Course.deleted.should == [@course2]
        end
      end
    end

  end
end
