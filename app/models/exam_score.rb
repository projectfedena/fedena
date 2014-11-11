# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class ExamScore < ActiveRecord::Base
  belongs_to :student
  belongs_to :exam
  belongs_to :grading_level

  before_save :calculate_grade
  before_save :check_existing

  validate :marks_cannot_be_greater_than_maximum_marks
  validates_presence_of :student_id
  validates_presence_of :exam_id, :message => "Name/Batch Name/Subject Code is invalid"
  validates_numericality_of :marks, :allow_nil => true

  def calculate_percentage
    percentage = self.marks.to_f * 100 / self.exam.maximum_marks.to_f
  end

  def exam_groups_from(batch, type)
    if type == 'grouped'
      exam_group_ids = GroupedExam.find_all_by_batch_id(batch).map(&:exam_group_id)
      ExamGroup.find_all_by_id(exam_group_ids)
    else
      ExamGroup.find_all_by_batch_id(batch)
    end
  end

  def grouped_exam_subject_total(subject, student, type, batch = "")
    batch = student.batch_id if batch.blank?
    exam_groups = exam_groups_from(batch, type)
    total_marks = 0
    exam_groups.each do |exam_group|
      if exam_group.exam_type != 'Grades'
        exam = Exam.find_by_subject_id_and_exam_group_id(subject.id, exam_group.id)
        if exam.present?
          exam_score = ExamScore.find_by_student_id_and_exam_id(student.id, exam.id)
          total_marks += exam_score && exam_score.marks ? exam_score.marks : 0
        end
      end
    end
    total_marks.to_f
  end

  def var_from(batch_id)
    ExamGroup.find_all_by_batch_id(batch_id).map do |group|
      1 if group.exam_type == 'Grades'
    end.compact
  end

  def batch_wise_aggregate(student, batch)
    if var_from(batch.id).empty?
      grouped_exams = GroupedExam.find_all_by_batch_id(batch.id)
      exam_groups = if grouped_exams.empty?
        ExamGroup.find_all_by_batch_id(batch.id)
      else
        ExamGroup.find_all_by_id(grouped_exams.map(&:exam_group_id))
      end
      max_total = 0
      marks_total = 0
      exam_groups.each do |exam_group|
        max_total += exam_group.total_marks(student)[1]
        marks_total += exam_group.total_marks(student)[0]
      end
      marks_total * 100 / max_total unless max_total == 0
    else
      nil
    end
  end

  private

  def marks_cannot_be_greater_than_maximum_marks
    if marks.present? && exam.present? && exam.maximum_marks.to_f < marks.to_f
      errors.add(:marks, 'cannot be greater than maximum marks')
    end
  end

  def check_existing
    exam_score = ExamScore.first(:conditions => {:exam_id => self.exam_id, :student_id => self.student_id})
    if exam_score
      self.id = exam_score.id
      self.instance_variable_set("@new_record",false)    #If the record exists,then make the new record as a copy of the existing one and allow rails to chhose
                                                         #the update operation instead of insert.
    end
    true
  end

  def calculate_grade
    exam_group = exam.exam_group
    exam_type = exam_group.exam_type
    if exam_type != 'Grades'
      if self.marks.present?
        percent_score = self.marks.to_i * 100 / self.exam.maximum_marks
        grade = GradingLevel.percentage_to_grade(percent_score, self.exam.exam_group.batch_id)
        self.grading_level_id = grade.id if exam_type == 'MarksAndGrades'
      else
        self.grading_level_id = nil
      end
    end
    true
  end

end
