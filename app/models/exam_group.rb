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
class ExamGroup < ActiveRecord::Base
  attr_accessor :maximum_marks, :minimum_marks, :weightage

  belongs_to :batch
  belongs_to :grouped_exam
  belongs_to :cce_exam_category
  has_many :exams, :dependent => :destroy

  accepts_nested_attributes_for :exams
  validates_presence_of :name
  validates_associated :exams
  validates_uniqueness_of :cce_exam_category_id, :scope => :batch_id, :message => "already assigned for another Exam Group", :unless => lambda { |e| e.cce_exam_category_id.nil? }

  before_save :set_exam_date
  before_validation :grade_exam_marks

  def removable?
    self.exams.all?{ |e| e.removable? }
  end

  # TODO: all these methods can be refactor using meta programing
  def batch_average_marks(marks)
    batch_students = batch.students
    total_students_marks = 0
    students_attended = []
    exams.each do |exam|
      batch_students.each do |student|
        exam_score = ExamScore.find_by_student_id_and_exam_id(student.id, exam.id)
        if exam_score && exam_score.marks
          total_students_marks += exam_score.marks
          students_attended << student.id unless students_attended.include?(student.id)
        end
      end
    end

    batch_average_marks = if students_attended.size == 0
      0
    else
      total_students_marks / students_attended.size
    end
    batch_average_marks if marks == 'marks'
  end

  def weightage
    grp = GroupedExam.find_by_batch_id_and_exam_group_id(self.batch.id, self.id)
    grp.present? ? grp.weightage : 0
  end

  def archived_batch_average_marks(marks)
    batch_students = ArchivedStudent.find_all_by_batch_id(self.batch.id)
    total_students_marks = 0
    students_attended = []
    exams.each do |exam|
      batch_students.each do |student|
        exam_score = ArchivedExamScore.find_by_student_id_and_exam_id(student.id, exam.id)
        if exam_score && exam_score.marks
          total_students_marks += exam_score.marks
          students_attended << student.id unless students_attended.include?(student.id)
        end
      end
    end
    batch_average_marks = if students_attended.size == 0
      0
    else
      total_students_marks / students_attended.size
    end
    batch_average_marks if marks == 'marks'
  end

  def batch_average_percentage
  end

  def subject_wise_batch_average_marks(subject_id)
    subject = Subject.find(subject_id)
    exam = Exam.find_by_exam_group_id_and_subject_id(self.id, subject.id)
    batch_students = batch.students
    total_students_marks = 0
    students_attended = []

    batch_students.each do |student|
      exam_score = ExamScore.find_by_student_id_and_exam_id(student.id, exam.id)
      if exam_score.present?
        total_students_marks += (exam_score.marks || 0)
        students_attended << student.id unless students_attended.include?(student.id)
      end
    end

    batch_average_marks = if students_attended.size == 0
      0
    else
      total_students_marks / students_attended.size.to_f
    end
    batch_average_marks
  end

  def total_marks(student)
    exams = Exam.find_all_by_exam_group_id(self.id)
    total_marks = 0
    max_total = 0
    exams.each do |exam|
      exam_score = ExamScore.find_by_exam_id_and_student_id(exam.id, student.id)
      if exam_score.present?
        total_marks += (exam_score.marks || 0)
        max_total += exam.maximum_marks
      end
    end
    [total_marks, max_total]
  end

  def archived_total_marks(student)
    exams = Exam.find_all_by_exam_group_id(self.id)
    total_marks = 0
    max_total = 0
    exams.each do |exam|
      exam_score = ArchivedExamScore.find_by_exam_id_and_student_id(exam.id, student.id)
      total_marks = total_marks + (exam_score.marks || 0 ) unless exam_score.nil?
      max_total = max_total + exam.maximum_marks unless exam_score.nil?
    end
    result = [total_marks, max_total]
  end

  def course
    batch.course if batch
  end

  private

    def set_exam_date
      self.exam_date ||= Date.today
    end

    def grade_exam_marks
      if self.exam_type && self.exam_type.downcase == "grades"
        self.exams.each do |ex|
          ex.maximum_marks = 0
          ex.minimum_marks = 0
        end
      end
    end
end
