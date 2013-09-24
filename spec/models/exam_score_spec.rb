require 'spec_helper'

describe ExamScore do
  it { should belong_to(:student) }
  it { should belong_to(:exam) }
  it { should belong_to(:grading_level) }

  it { should validate_presence_of(:student_id) }
  it { should validate_presence_of(:exam_id).with_message("Name/Batch Name/Subject Code is invalid") }
  it { should validate_numericality_of(:marks) }

  context 'a exists record' do
    let(:student) { FactoryGirl.create(:student) }
    let(:exam) { FactoryGirl.create(:exam, :maximum_marks => 100) }
    let(:exam_score) { FactoryGirl.create(:exam_score, :marks => 30, :exam => exam, :student => student) }

    describe '#marks_cannot_be_greater_than_maximum_marks' do
      context 'when marks > exam.maximum_marks' do
        before do
          exam_score.marks = 80
          exam_score.exam.maximum_marks = 60
        end

        it 'is invalid' do
          exam_score.should be_invalid
        end
      end
    end

    describe '#check_existing' do
      let(:exam_score1) { FactoryGirl.build(:exam_score, :id => 22) }

      context 'found ExamScore with condition' do
        before { ExamScore.stub(:find).with(:first, :conditions => {:exam_id => exam.id,:student_id => student.id}).and_return(exam_score1) }

        context 'when save exam_score' do
          before { exam_score.save }

          it 'does set exam_score.id = exam_score1.id' do
            exam_score.id.should == 22
          end

          it 'does set instance_variable new_record to false' do
            exam_score.should_not be_new_record
          end
        end
      end
    end

    describe '#calculate_grade' do
      context 'exam_type != Grades, exam_type = MarksAndGrades' do
        before { exam_score.exam.exam_group.exam_type = 'MarksAndGrades' }

        context 'exam_score.marks is present' do
          before { exam_score.marks = 55 }

          context 'found GradingLevel.percentage_to_grade' do
            let(:grading_level) { FactoryGirl.create(:grading_level) }
            before { GradingLevel.stub(:percentage_to_grade).and_return(grading_level) }

            context 'when save exam_score' do
              before { exam_score.save }

              it 'does save grading_level_id with grading_level.id' do
                exam_score.grading_level_id.should ==  grading_level.id
              end
            end
          end
        end

        context 'exam_score.marks is nil' do
          before { exam_score.marks = nil }

          context 'when save exam_score' do
            before { exam_score.save }

            it 'does save grading_level_id = nil' do
              exam_score.grading_level_id.should be_nil
            end
          end
        end
      end
    end
  end

  describe '#calculate_percentage' do
    let(:exam) { FactoryGirl.build(:exam, :maximum_marks => 100)}
    let(:exam_score) { FactoryGirl.build(:exam_score, :marks => 30, :exam => exam) }

    it 'returns percentage' do
      exam_score.calculate_percentage.should == 30
    end
  end

  describe '#grouped_exam_subject_total' do
    let(:subject) { FactoryGirl.build(:subject) }
    let(:student) { FactoryGirl.build(:student, :batch_id => 7) }
    let(:exam_score) { FactoryGirl.build(:exam_score, :marks => 43) }

    context 'type == grouped' do
      context 'found all GroupedExam with batch_id' do
        let(:groupped_exam) { GroupedExam.new }
        before { GroupedExam.stub(:find_all_by_batch_id).and_return([groupped_exam]) }

        context 'found ExamGroup with exam_group_id' do
          let(:exam_group) { ExamGroup.new }
          before { ExamGroup.stub(:find).and_return(exam_group) }

          context 'exam_group.exam_type != Grades' do
            before { exam_group.exam_type = 'not grades' }

            context 'found Exam with subject_id, exam_group_id' do
              let(:exam) { FactoryGirl.build(:exam) }
              before { Exam.stub(:find_by_subject_id_and_exam_group_id).and_return(exam) }

              context 'found ExamScore with student_id' do
                before { ExamScore.stub(:find_by_student_id).and_return(exam_score) }

                it 'returns total_marks' do
                  exam_score.grouped_exam_subject_total(subject, student, 'grouped').should == 43
                end
              end
            end
          end

          context 'exam_group.exam_type = Grades' do
            before { exam_group.exam_type = 'Grades' }

            it 'returns total_marks = 0' do
              exam_score.grouped_exam_subject_total(subject, student, 'grouped').should == 0
            end
          end
        end
      end
    end

    context 'type != grouped' do
      context 'found all ExamGroup with batch_id' do
        let(:exam_group) { ExamGroup.new }
        before { ExamGroup.stub(:find_all_by_batch_id).and_return([exam_group]) }

        context 'exam_group.exam_type != Grades' do
          before { exam_group.exam_type = 'not grades' }

          context 'found Exam with subject_id, exam_group_id' do
            let(:exam) { FactoryGirl.build(:exam) }
            before { Exam.stub(:find_by_subject_id_and_exam_group_id).and_return(exam) }

            context 'found ExamScore with student_id' do
              before { ExamScore.stub(:find_by_student_id).and_return(exam_score) }

              it 'returns total_marks' do
                exam_score.grouped_exam_subject_total(subject, student, 'no grouped').should == 43
              end
            end
          end
        end

        context 'exam_group.exam_type = Grades' do
          before { exam_group.exam_type = 'Grades' }

          it 'returns total_marks = 0' do
            exam_score.grouped_exam_subject_total(subject, student, 'no grouped').should == 0
          end
        end
      end
    end
  end

  describe '#batch_wise_aggregate' do
    let(:batch) { FactoryGirl.create(:batch) }
    let(:student) { FactoryGirl.build(:student) }
    let(:exam_score) { FactoryGirl.build(:exam_score, :marks => 43) }

    context 'found ExamGroup with batch_id' do
      context 'exam_group.exam_type = Grades' do
        let(:exam_group) { ExamGroup.new(:exam_type => 'Grades') }
        before { ExamGroup.stub(:find_all_by_batch_id).with(batch.id).and_return([exam_group]) }

        context 'var.empty? is false' do
          it 'returns aggr = nil' do
            exam_score.batch_wise_aggregate(student, batch).should be_nil
          end
        end
      end

      context 'exam_group.exam_type != Grades' do
        let(:exam_group) { ExamGroup.new(:exam_type => 'no Grades') }
        before { ExamGroup.stub(:find_all_by_batch_id).with(batch.id).and_return([exam_group]) }

        context 'var.empty? is true' do
          context 'grouped_exam.empty? is false' do
            context 'found all GroupedExam with batch_id' do
            let(:groupped_exam) { GroupedExam.new(:exam_group_id => 10) }
            before { GroupedExam.stub(:find_all_by_batch_id).with(batch.id).and_return([groupped_exam]) }

              context 'found ExamGroup with id = groupped_exam.exam_group_id)' do
                let(:exam_group1) { ExamGroup.new }
                before { ExamGroup.stub(:find).with(10).and_return(exam_group1) }

                context 'max_total != 0' do
                  before { exam_group1.stub(:total_marks).and_return([10,20]) }

                  it 'returns aggr' do
                    exam_score.batch_wise_aggregate(student, batch).should == 50
                  end
                end

                context 'max_total = 0' do
                  before { exam_group1.stub(:total_marks).and_return([0,20]) }

                  it 'returns aggr' do
                    exam_score.batch_wise_aggregate(student, batch).should == 0
                  end
                end
              end
            end
          end

          context 'grouped_exam.empty? is true' do
            context 'not found all GroupedExam with batch_id' do
            before { GroupedExam.stub(:find_all_by_batch_id).with(batch.id).and_return([]) }

              context 'found all ExamGroup with batch_id' do
                let(:exam_group1) { ExamGroup.new }
                before { ExamGroup.stub(:find_all_by_batch_id).with(batch.id).and_return([exam_group1]) }

                context 'max_total != 0' do
                  before { exam_group1.stub(:total_marks).and_return([10,20]) }

                  it 'returns aggr' do
                    exam_score.batch_wise_aggregate(student, batch).should == 50
                  end
                end

                context 'max_total = 0' do
                  before { exam_group1.stub(:total_marks).and_return([0,20]) }

                  it 'returns aggr' do
                    exam_score.batch_wise_aggregate(student, batch).should == 0
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end