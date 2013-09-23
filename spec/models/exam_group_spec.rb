require 'spec_helper'

describe ExamGroup do
  it { should belong_to(:batch) }
  xit { should belong_to(:grouped_exam) }
  it { should belong_to(:cce_exam_category) }
  it { should have_many(:exams).dependent(:destroy) }
  it { should validate_presence_of(:name) }

  describe '#validate_uniqueness_of cce_exam_category_id' do
    context 'cce_exam_category_id is nil' do
      let!(:exam_group) { FactoryGirl.create(:exam_group, :cce_exam_category_id => '') }

      it { should_not validate_uniqueness_of(:cce_exam_category_id).with_message('already assigned for another Exam Group') }
    end

    context 'cce_exam_category_id is not nil?' do
      let!(:exam_group) { FactoryGirl.create(:exam_group, 
        :cce_exam_category => FactoryGirl.create(:cce_exam_category)) }

      it { should validate_uniqueness_of(:cce_exam_category_id).with_message('already assigned for another Exam Group') }
    end
  end

  describe '#validate_associated exams' do
    before do
      @exam_group = FactoryGirl.build(:exam_group)
      @exam_group.exams.build
    end

    it 'returns invalid exam_group' do
      @exam_group.save.should be_false
    end
  end

  describe '#set_exam_date' do
    context 'exam_date is nil' do 
      let!(:exam_group) { FactoryGirl.build(:exam_group, :exam_date => nil) }

      it 'save current date' do
        exam_group.save
        exam_group.exam_date.should == Date.current
      end
    end

    context 'exam_date is not nil' do 
      let!(:exam_group) { FactoryGirl.build(:exam_group, :exam_date => Date.new(2013, 9, 21)) }

      it 'save exam date' do
        exam_group.save
        exam_group.exam_date.should == Date.new(2013, 9, 21)
      end
    end
  end

  describe '#removable?' do
    let(:exam_score) { ExamScore.new }
    let(:exam) { Exam.new(:exam_scores => [exam_score]) }
    let(:exam_group) { ExamGroup.new(:exams => [exam]) }

    context 'exam is removable?' do
      before do
        exam_score.marks = 10
        exam_score.grading_level_id = 99
      end

      it 'returns false' do
        exam_group.should_not be_removable
      end
    end

    context 'exam is not removable?' do
      before do
        exam_score.marks = nil
        exam_score.grading_level_id = nil
      end

      it 'returns true' do
        exam_group.should be_removable
      end
    end
  end

  describe '#grade_exam_marks' do
    let(:sub) { Subject.new(:batch => Batch.new(:course => Course.new, :name => 'batchname')) }
    let(:exam) { FactoryGirl.build(:exam, :subject => sub) }
    let(:exam_group) { FactoryGirl.create(:exam_group, :exam_type => 'Grades', :exams => [exam]) }

    it 'returns maximum_marks and minimum_marks' do
      exam_group.exams.first.maximum_marks.should == 0
      exam_group.exams.first.minimum_marks.should == 0
    end
  end

  describe '#batch_average_marks' do
    before do
      @student1 = FactoryGirl.create(:student)
      @student2 = FactoryGirl.create(:student)
      @batch = FactoryGirl.create(:batch, :course => FactoryGirl.create(:course), :students => [@student1, @student2])
      @subject = FactoryGirl.create(:subject, :batch => @batch)
      @exam1 = FactoryGirl.build(:exam, :subject => @subject)
      @exam2 = FactoryGirl.build(:exam, :subject => @subject)
      @exam_group = FactoryGirl.create(:exam_group, 
        :exams => [@exam1, @exam2],
        :batch => @batch)
    end

    context 'ExamScore is found' do
      before do
        ExamScore.create(:student => @student1, :exam => @exam1, :marks => 80)
        ExamScore.create(:student => @student2, :exam => @exam2, :marks => 90)
      end

      it 'returns batch_average_marks' do
        @exam_group.batch_average_marks('marks').should == 85
      end
    end

    context 'ExamScore is not found' do
      before do
        ExamScore.create(:student => @student1, :exam => @exam1)
      end

      it 'returns batch_average_marks' do
        @exam_group.batch_average_marks('marks').should == 0
      end
    end
  end

  describe '#weightage' do
    let(:batch) { FactoryGirl.create(:batch) }
    let(:exam_group) { FactoryGirl.create(:exam_group, :batch => batch) }

    context 'weightage is not found' do
      it 'returns weightage' do
        exam_group.weightage.should == 0
      end
    end

    context 'weightage is found' do
      before { GroupedExam.create(:exam_group_id => exam_group.id, :batch_id => batch.id, :weightage => 50) }

      it 'returns weightage' do
        exam_group.weightage.should == 50
      end
    end
  end

  describe '#archived_batch_average_marks' do
    before do
      @batch = FactoryGirl.create(:batch, :course => FactoryGirl.create(:course))
      @archived_student1 = FactoryGirl.create(:archived_student, :batch => @batch)
      @archived_student2 = FactoryGirl.create(:archived_student, :batch => @batch)
      @subject = FactoryGirl.create(:subject, :batch => @batch)
      @exam1 = FactoryGirl.build(:exam, :subject => @subject)
      @exam2 = FactoryGirl.build(:exam, :subject => @subject)
      @exam_group = FactoryGirl.create(:exam_group, 
        :exams => [@exam1, @exam2],
        :batch => @batch)
    end

    context 'ArchivedStudent is found' do
      before do
        ArchivedExamScore.create(:student_id => @archived_student1.id, :exam => @exam1, :marks => 72)
        ArchivedExamScore.create(:student_id => @archived_student2.id, :exam => @exam2, :marks => 68)
      end

      it 'returns batch_average_marks' do
        @exam_group.archived_batch_average_marks('marks').should == 70
      end
    end

    context 'ExamScore is not found' do
      before { ArchivedExamScore.create(:student_id => @archived_student1.id, :exam => @exam1) }

      it 'returns zero' do
        @exam_group.archived_batch_average_marks('marks').should == 0
      end
    end
  end

  describe 'subject_wise_batch_average_marks' do
    before do
      @student1 = FactoryGirl.create(:student)
      @student2 = FactoryGirl.create(:student)
      @batch = FactoryGirl.create(:batch, 
        :course => FactoryGirl.create(:course),
        :students => [@student1, @student2])
      @subject = FactoryGirl.create(:subject, :batch => @batch)
      @exam_group = FactoryGirl.create(:exam_group, :batch => @batch)
      @exam = FactoryGirl.create(:exam, :exam_group => @exam_group, :subject => @subject)
    end

    context 'ExamScore is found' do
      before do
        ExamScore.create(:student => @student1, :exam => @exam, :marks => 80)
        ExamScore.create(:student => @student2, :exam => @exam, :marks => 70)
      end

      it 'returns average_marks' do
        @exam_group.subject_wise_batch_average_marks(@subject.id).should == 75
      end
    end

    context 'ExamScore is not found' do
      before do
        ExamScore.create(:student => @student1, :exam => @exam)
      end

      it 'returns zero' do
        @exam_group.subject_wise_batch_average_marks(@subject.id).should == 0
      end
    end
  end

  describe '#total_marks' do
    before do
      @batch = FactoryGirl.create(:batch, :course => FactoryGirl.create(:course))
      @subject = FactoryGirl.create(:subject, :batch => @batch)
      @student = FactoryGirl.create(:student)
      @exam_group = FactoryGirl.create(:exam_group)
      @exam1 = FactoryGirl.create(:exam, :maximum_marks => 100, :exam_group => @exam_group, :subject => @subject)
      @exam2 = FactoryGirl.create(:exam, :maximum_marks => 90, :exam_group => @exam_group, :subject => @subject)
    end

    context 'ExamScore is found' do
      before do
        ExamScore.create(:student => @student, :exam => @exam1, :marks => 82)
        ExamScore.create(:student => @student, :exam => @exam2, :marks => 68)
      end

      it 'returns total_marks' do
        @exam_group.total_marks(@student).should == [150, 190]
      end
    end

    context 'ExamScore is not found' do
      before { ExamScore.create(:student => @student, :exam => @exam1) }

      it 'returns total_marks' do
        @exam_group.total_marks(@student).should == [0, 100]
      end
    end
  end

  describe '#archived_total_marks' do
    before do
      @batch = FactoryGirl.create(:batch, :course => FactoryGirl.create(:course))
      @subject = FactoryGirl.create(:subject, :batch => @batch)
      @archived_student = FactoryGirl.create(:archived_student)
      @exam_group = FactoryGirl.create(:exam_group)
      @exam1 = FactoryGirl.create(:exam, :maximum_marks => 100, :exam_group => @exam_group, :subject => @subject)
      @exam2 = FactoryGirl.create(:exam, :maximum_marks => 90, :exam_group => @exam_group, :subject => @subject)
    end

    context 'ArchivedExamScore is found' do
      before do
        ArchivedExamScore.create(:student_id => @archived_student.id, :exam => @exam1, :marks => 82)
        ArchivedExamScore.create(:student_id => @archived_student.id, :exam => @exam2, :marks => 68)
      end

      it 'returns archived_total_marks' do
        @exam_group.archived_total_marks(@archived_student).should == [150, 190]
      end
    end

    context 'ArchivedExamScore is not found' do
      before { ArchivedExamScore.create(:student_id => @archived_student.id, :exam => @exam1) }

      it 'returns archived_total_marks' do
        @exam_group.archived_total_marks(@archived_student).should == [0, 100]
      end
    end
  end

  describe '#course' do
    context 'course is found' do
      before do
        @course = FactoryGirl.create(:course)
        @batch = FactoryGirl.create(:batch, :course => @course)
        @exam_group = FactoryGirl.create(:exam_group, :batch => @batch)
      end

      it 'returns course' do
        @exam_group.course.should == @course
      end
    end

    context 'course is not found' do
      before do
        @course = FactoryGirl.create(:course)
        @batch = FactoryGirl.create(:batch)
        @exam_group = FactoryGirl.create(:exam_group, :batch => @batch)
      end

      it 'returns nil' do
        @exam_group.course.should be_nil
      end
    end
  end
end
