require 'spec_helper'

describe Exam do

  describe 'validation' do
    it { should belong_to(:exam_group) }

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

    describe 'custom validation' do
      let(:exam_group) { FactoryGirl.build(:exam_group) }
      let(:sub) { Subject.new(:batch => Batch.new(:course => Course.new, :name => 'batchname')) }
      let(:exam) { FactoryGirl.create(:exam, :exam_group => exam_group, :subject => sub) }

      describe '#minmarks_cant_be_more_than_maxmarks?' do
        it 'validates that minimum marks are not larger than maximum marks' do
          exam.maximum_marks = 50
          exam.minimum_marks = 51
          exam.should be_invalid
        end
      end

      describe '#end_time_cannot_before_start_time?' do
        it 'validates end time cannot before start time' do
          exam.end_time = Date.current - 10.days
          exam.start_time = Date.current
          exam.should be_invalid
        end
      end
    end
  end

  describe '#validation_should_present?' do
    let(:exam) { Exam.new(:exam_group => ExamGroup.new) }

    context 'exam_type = grades' do
      it 'returns false' do
        exam.exam_group.exam_type = "Grades"
        exam.should_not be_validation_should_present
      end
    end

    context 'exam_type != grades' do
      it 'returns true' do
        exam.should be_validation_should_present
      end
    end
  end

  describe '#removable?' do
    let(:exam_score) { ExamScore.new }
    let(:exam) { Exam.new(:exam_scores => [exam_score]) }

    context 'exam_score marks and grading_level_id are not nil' do
      before do
        exam_score.marks = 10
        exam_score.grading_level_id = 99
      end

      it 'returns false' do
        exam.should_not be_removable
      end
    end

    context 'exam score marks and grading_level_id are nil' do
      before do
        exam_score.marks = nil
        exam_score.grading_level_id = nil
      end

      it 'returns true' do
        exam.should be_removable
      end
    end
  end

  describe '#score_for' do
    let(:exam) { Exam.new }

    context 'when no student with student_id 5' do
      it 'returns ExamScore.new' do
        exam.score_for(5).should be_new_record
      end
    end

    context 'when have student with student_id 5' do
      let(:exam_score) { ExamScore.new(:marks => 85, :grading_level_id => 35) }
      before { exam.exam_scores.stub(:find_or_initialize_by_student_id).with(5).and_return(exam_score) }

      it 'returns @exam_score' do
        exam.score_for(5).should equal(exam_score)
      end
    end
  end

  describe '#class_average_marks' do
    let(:exam) { Exam.new }

    context 'not found exam score' do
      it 'returns 0' do
        exam.class_average_marks.should == 0
      end
    end

    context 'found exam score' do
      before do
        exam_score1 = ExamScore.new(:marks => 10)
        exam_score2 = ExamScore.new(:marks => 20)
        ExamScore.stub(:find_all_by_exam_id).with(exam).and_return([exam_score1, exam_score2])
      end

      it 'returns @exam_score' do
        exam.class_average_marks.should == 15
      end
    end
  end

  describe '#fa_groups' do
    let(:exam) { Exam.new(:exam_group => ExamGroup.new, :subject => Subject.new) }

    context 'not found fa_groups' do
      it 'returns empty array' do
        exam.fa_groups.should be_empty
      end
    end

    context 'found fa_groups' do
      before do
        exam.exam_group.cce_exam_category_id = 5
        @fa_group1 = FaGroup.new(:cce_exam_category_id => 5)
        @fa_group2 = FaGroup.new(:cce_exam_category_id => 7)
        exam.subject.fa_groups = [@fa_group1, @fa_group2]
      end

      it 'returns fa_group same cce_exam_category_id with exam_group' do
        exam.fa_groups.should == [@fa_group1]
      end
    end
  end

  describe 'private method' do
    let(:exam) { Exam.new(:exam_group => FactoryGirl.create(:exam_group), :subject => Subject.new(:batch => Batch.new(:course => Course.new))) }
    before { exam.stub(:valid?).and_return(true) }

    describe '#update_weightage' do
      before { exam.exam_group.exam_date = nil }

      context 'weightage nil' do
        before { exam.weightage = nil }

        it 'update weightage to 0' do
          exam.save
          exam.weightage.should == 0
        end
      end

      context 'weightage not nil' do
        before { exam.weightage = 5 }

        it 'does not update weightage' do
          exam.save
          exam.weightage.should == 5
        end
      end
    end

    describe '#update_exam_group_date' do
      context 'exam group date nil' do
        before do
          exam.exam_group.exam_date = nil
          exam.save
        end

        it 'dont update exam_group_date' do
          exam.exam_group.exam_date.should be_nil
        end
      end

      context 'exam group date not nil && start_date < exam group date' do
        before do
          exam.start_time = Date.current - 10.days
          exam.exam_group.exam_date = Date.current
          exam.save
        end

        it 'update exam_group_date with start_time' do
          exam.exam_group.exam_date.should == exam.start_time.to_date
        end
      end
    end

    describe '#update_exam_event' do
      before do
        exam.start_time = Date.current - 10.days
        exam.end_time = Date.current
        exam.save
      end

      context 'exam event blank' do
        before { exam.update_attributes(:weightage => 10) }

        it 'dont update exam event' do
          exam.event.should be_nil
        end
      end

      context 'exam event not blank' do
        before do
          exam.event = Event.new
          exam.update_attributes(:weightage => 10)
        end

        it 'update exam event with start_time and end_time' do
          exam.event.start_date.should == exam.start_time
          exam.event.end_date.should == exam.end_time
        end
      end
    end

    describe '#create_exam_event' do
      before do
        exam.start_time = Date.current - 10.days
        exam.end_time = Date.current
      end

      context 'exam event blank' do
        it 'create Event,BatchEvent and update exam event id' do
          exam.save
          Event.all.count.should == 1
          BatchEvent.all.count.should == 1
          exam.event_id.should_not be_nil
        end
      end

      context 'exam event not blank' do
        before { exam.event = Event.new }

        it 'dont create Event,BatchEvent and update exam event id' do
          exam.save
          Event.all.count.should == 0
          BatchEvent.all.count.should == 0
          exam.event_id.should be_nil
        end
      end
    end

  end
end