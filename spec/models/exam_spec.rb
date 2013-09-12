require 'spec_helper'

describe Exam do
  it { should belong_to(:exam_group) }
  it { should belong_to(:subject) }

  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }
  it { should validate_numericality_of(:maximum_marks) }
  it { should validate_numericality_of(:minimum_marks) }
  it { should belong_to(:exam_group) }
  it { should belong_to(:subject).conditions(:is_deleted => false) }

  it { should have_one(:event) }

  it { should have_many(:exam_scores) }
  it { should have_many(:archived_exam_scores) }
  it { should have_many(:previous_exam_scores) }
  it { should have_many(:assessment_scores) }

  context 'a new exam record' do
    before do
      @exam = Factory.build(:exam)
      @exam_group = Factory.create(:exam_group, :exam_date => Date.today)
      @exam.exam_group = @exam_group
    end

    it 'should not have minimum marks more than maximum marks' do
      @exam.maximum_marks = 50
      @exam.minimum_marks = 51
      @exam.should be_invalid
    end

  end
end
