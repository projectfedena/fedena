require 'spec_helper'

describe GradingLevel do

  it { should belong_to(:batch) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:min_score) }

  context 'batch has gpa'  do
    before { subject.stub(:batch_has_gpa?).and_return(true) }
    it { should validate_presence_of(:credit_points) }
  end

  context 'batch has no gpa'  do
    before { subject.stub(:batch_has_gpa?).and_return(false) }
    it { should_not validate_presence_of(:credit_points) }
  end

  # it { should validate_uniqueness_of(:name).scoped_to(:batch_id, :is_deleted).case_insensitive }

  context 'validation grading level' do
    before do
      @grading_level1 = Factory.create(:grading_level, :batch => nil, :is_deleted => false)
      @grading_level2 = Factory.create(:grading_level, :is_deleted => false)
    end

    describe 'scope_name test' do
      describe '.default' do
        it 'returns default grading level' do
          GradingLevel.default.should == [@grading_level1]
        end
      end

      describe '.for_batch' do
        it 'return for_batch grading level' do
          GradingLevel.for_batch(@grading_level2.batch_id).should == [@grading_level2]
        end
      end
    end
  end
end
