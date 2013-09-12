require 'spec_helper'

describe ExamGroup do
  context 'a new exam group' do
    before { @exam_group = Factory.create(:exam_group) }

    it { should belong_to(:batch) }
    it { should have_many(:exams).dependent(:destroy) }
    it { should belong_to(:cce_exam_category) }

    it 'should save current date if date is not given' do
      @exam_group.exam_date = nil
      @exam_group.save
      @exam_group.exam_date.should == Date.today
    end
  end
end
