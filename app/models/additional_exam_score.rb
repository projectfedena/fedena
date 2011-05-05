class AdditionalExamScore < ActiveRecord::Base
  belongs_to :student
  belongs_to :additional_exam
  belongs_to :grading_level

  before_save :calculate_grade
  
  private
  def calculate_grade
    additional_exam = self.additional_exam
    additional_exam_group = additional_exam.additional_exam_group
    additional_exam_type = additional_exam_group.exam_type
    unless additional_exam_type == 'Grades'
      unless self.marks.nil?
        percent_score = self.marks.to_i * 100 / self.additional_exam.maximum_marks
        grade = GradingLevel.percentage_to_grade(percent_score, self.student.batch_id)
        self.grading_level_id = grade.id if additional_exam_type == 'MarksAndGrades'
      else
        self.grading_level_id = nil
      end

    end
  end

end
