require 'spec_helper'

describe ArchivedExamScore do

  it { should belong_to(:student) }
  it { should belong_to(:exam) }
  it { should belong_to(:grading_level) }

  context '#calculate_grade' do
    let(:student) { FactoryGirl.create(:student, :batch_id => 11) }
    let(:exam) { FactoryGirl.create(:exam, :maximum_marks => 100) }
    let(:archive_exam_score) { ArchivedExamScore.new(:marks => 30, :exam => exam, :student => student) }

    context 'exam_type != Grades, exam_type = MarksAndGrades' do
      before { archive_exam_score.exam.exam_group.exam_type = 'MarksAndGrades' }

      context 'found ArchivedStudent with student_id' do
        before { ArchivedStudent.stub(:find).and_return(student) }

        context 'archive_exam_score.marks is present' do
          before { archive_exam_score.marks = 55 }

          context 'found GradingLevel.percentage_to_grade' do
            let(:grading_level) { FactoryGirl.create(:grading_level) }
            before { GradingLevel.stub(:percentage_to_grade).and_return(grading_level) }

            context 'when save archive_exam_score' do
              before { archive_exam_score.save }

              it 'does save grading_level_id with grading_level.id' do
                archive_exam_score.grading_level_id.should ==  grading_level.id
              end
            end
          end
        end

        context 'archive_exam_score.marks is nil' do
          before { archive_exam_score.marks = nil }

          context 'when save archive_exam_score' do
            before { archive_exam_score.save }

            it 'does save grading_level_id = nil' do
              archive_exam_score.grading_level_id.should be_nil
            end
          end
        end
      end
    end
  end


  describe '#calculate_percentage' do
    let(:exam) { Exam.new(:maximum_marks => 100) }
    let(:archive_exam) { ArchivedExamScore.new(:marks => 70, :exam => exam) }

    it 'returns percentage' do
      archive_exam.calculate_percentage.should == 70
    end
  end

  describe '#grouped_exam_subject_total' do
    let(:subject) { FactoryGirl.build(:subject) }
    let(:student) { FactoryGirl.build(:student, :batch_id => 7) }
    let(:archive_exam_score) { ArchivedExamScore.new(:marks => 43) }

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

              context 'found ArchivedExamScore with student_id' do
                before { ArchivedExamScore.stub(:find_by_student_id).and_return(archive_exam_score) }

                it 'returns total_marks' do
                  archive_exam_score.grouped_exam_subject_total(subject, student, 'grouped').should == 43
                end
              end
            end
          end

          context 'exam_group.exam_type = Grades' do
            before { exam_group.exam_type = 'Grades' }

            it 'returns total_marks = 0' do
              archive_exam_score.grouped_exam_subject_total(subject, student, 'grouped').should == 0
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

            context 'found ArchivedExamScore with student_id' do
              before { ArchivedExamScore.stub(:find_by_student_id).and_return(archive_exam_score) }

              it 'returns total_marks' do
                archive_exam_score.grouped_exam_subject_total(subject, student, 'no grouped').should == 43
              end
            end
          end
        end

        context 'exam_group.exam_type = Grades' do
          before { exam_group.exam_type = 'Grades' }

          it 'returns total_marks = 0' do
            archive_exam_score.grouped_exam_subject_total(subject, student, 'no grouped').should == 0
          end
        end
      end
    end
  end


  describe '#batch_wise_aggregate' do
    let(:batch) { FactoryGirl.create(:batch) }
    let(:student) { FactoryGirl.build(:student) }
    let(:archive_exam_score) { ArchivedExamScore.new(:marks => 43) }

    context 'found ExamGroup with batch_id' do
      context 'exam_group.exam_type = Grades' do
        let(:exam_group) { ExamGroup.new(:exam_type => 'Grades') }
        before { ExamGroup.stub(:find_all_by_batch_id).with(batch.id).and_return([exam_group]) }

        context 'var.empty? is false' do
          it 'returns aggr = nil' do
            archive_exam_score.batch_wise_aggregate(student, batch).should be_nil
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
                  before { exam_group1.stub(:archived_total_marks).and_return([10,20]) }

                  it 'returns aggr' do
                    archive_exam_score.batch_wise_aggregate(student, batch).should == 50
                  end
                end

                context 'max_total = 0' do
                  before { exam_group1.stub(:archived_total_marks).and_return([0,20]) }

                  it 'returns aggr' do
                    archive_exam_score.batch_wise_aggregate(student, batch).should == 0
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
                  before { exam_group1.stub(:archived_total_marks).and_return([10,20]) }

                  it 'returns aggr' do
                    archive_exam_score.batch_wise_aggregate(student, batch).should == 50
                  end
                end

                context 'max_total = 0' do
                  before { exam_group1.stub(:archived_total_marks).and_return([0,20]) }

                  it 'returns aggr' do
                    archive_exam_score.batch_wise_aggregate(student, batch).should == 0
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
