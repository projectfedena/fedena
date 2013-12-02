require 'spec_helper'

describe Subject do
  before { @subject = FactoryGirl.create(:general_subject, :batch => FactoryGirl.create(:batch)) }

  describe 'validation'  do
    it { should belong_to(:batch) }
    it { should belong_to(:elective_group) }
    it { should have_many(:timetable_entries) }
    it { should have_many(:employees_subjects) }
    it { should have_many(:employees).through(:employees_subjects) }
    it { should have_many(:students_subjects) }
    it { should have_many(:students).through(:students_subjects) }
    it { should have_many(:grouped_exam_reports) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:max_weekly_classes) }
    it { should validate_presence_of(:batch_id) }
    it { should validate_numericality_of(:max_weekly_classes) }
    it { should validate_numericality_of(:amount) }

    describe 'validate presence of credit_hours' do
      context 'check_grade_type is true' do
        before { @subject.stub(:check_grade_type).and_return(true) }
        it { should validate_presence_of(:credit_hours) }
      end

      context 'check_grade_type is false' do
        before { @subject.stub(:check_grade_type).and_return(false) }
        it { should_not validate_presence_of(:credit_hours) }
      end
    end

    describe 'validate uniqueness of code' do
      context 'subject is deleted' do
        before { @subject.update_attributes(:is_deleted => true) }
        it { should_not validate_uniqueness_of(:code).scoped_to(:batch_id,:is_deleted) }
      end

      context 'subject is active' do
        before { @subject.update_attributes(:is_deleted => false) }
        it { should validate_uniqueness_of(:code).scoped_to(:batch_id,:is_deleted) }
      end
    end
  end

  describe '#fa_group_valid' do
    context 'have more than 2 fa group under a single exam category' do
      before do
        fa_group = FactoryGirl.create(:fa_group)
        @subject.fa_groups = [fa_group, fa_group, fa_group]
        @subject.save
      end

      it 'is invalid' do
        @subject.should be_invalid
      end
    end
  end

  describe '#inactivate' do
    it 'sets is_deleted true' do
      @subject.inactivate
      @subject.should be_is_deleted
    end
  end

  describe '#check_grade_type' do
    context 'with no batch'  do
      before { @subject.batch = nil }
      it 'returns false' do
        @subject.check_grade_type.should be_false
      end
    end

    context 'have an initial batch'  do
      context 'gpa and cwa are disabled in Configuration' do
        before do
          @subject.batch.stub(:gpa_enabled?).and_return(false)
          @subject.batch.stub(:cwa_enabled?).and_return(false)
        end
        it 'returns false' do
          @subject.check_grade_type.should be_false
        end
      end

      context 'gpa or cwa are enabled in Configuration' do
        it 'returns true' do
          @subject.batch.stub(:gpa_enabled?).and_return(true)
          @subject.check_grade_type.should be_true
        end

        it 'returns true' do
          @subject.batch.stub(:cwa_enabled?).and_return(true)
          @subject.check_grade_type.should be_true
        end
      end
    end
  end

  describe '#lower_day_grade and #lower_day_grade' do
    before do
      @subject.stub(:elective_group).and_return(true)
      @subject.stub(:elective_group_id).and_return(10)

      @employee1 = FactoryGirl.build(:employee,
        :employee_grade => FactoryGirl.create(:employee_grade, :max_hours_day => 14, :max_hours_week => 50))
      @employee2 = FactoryGirl.build(:employee,
        :employee_grade => FactoryGirl.create(:employee_grade, :max_hours_day => 10, :max_hours_week => 55))
      @subject.employees << [@employee1, @employee2]

      Subject.stub(:find_all_by_elective_group_id).with(@subject.elective_group_id).and_return([@subject])
    end

    describe '#lower_day_grade' do
      it 'returns employee lower_day_grade' do
        @subject.lower_day_grade.should == @employee2
      end
    end

    describe '#lower_week_grade' do
      it 'returns employee lower_week_grade' do
        @subject.lower_week_grade.should == @employee1
      end
    end
  end

  describe '#exam_not_created' do
    before do
      @exam = FactoryGirl.build(:exam, :exam_group_id => 5)
    end

    context 'exam not created' do
      it 'returns true' do
        @subject.exam_not_created(@exam.exam_group_id).should be_true
      end
    end

    context 'exam created' do
      before { Exam.stub(:find_all_by_exam_group_id_and_subject_id).with(@exam.exam_group_id,@subject.id).and_return([@exam]) }

      it 'returns false' do
        @subject.exam_not_created(@exam.exam_group_id).should be_false
      end
    end
  end

  describe '#no_exam_for_batch' do
    before do
      @grouped_exam = GroupedExam.new(:exam_group_id => 5)
      GroupedExam.stub(:find_all_by_batch_id).with(@subject.batch_id).and_return([@grouped_exam])
      @subject.should_receive(:exam_not_created).with([@grouped_exam.exam_group_id])
    end

    it 'returns #exam_not_created([5])' do
      @subject.no_exam_for_batch(@subject.batch_id)
    end
  end
end

describe 'scope_name test' do
  before do
    @subject1 = FactoryGirl.create(:general_subject, :batch => FactoryGirl.create(:batch),
      :no_exams => true, :is_deleted => false)
    @subject2 = FactoryGirl.create(:general_subject, :batch => FactoryGirl.create(:batch),
      :no_exams => false, :is_deleted => false)
  end

  describe '.for_batch' do
    it 'returns active subject with batch' do
      Subject.for_batch(@subject1.batch_id).should == [@subject1]
    end
  end

  describe '.without_exams' do
    it 'returns subject without exam' do
      Subject.without_exams.should == [@subject2]
    end
  end

  describe '.active' do
    it 'returns active subject' do
      @active_subjects = Subject.active
      @active_subjects.count.should == 2
      @active_subjects.should include(@subject1)
      @active_subjects.should include(@subject2)
    end
  end

end
