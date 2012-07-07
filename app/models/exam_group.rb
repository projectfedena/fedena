#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class ExamGroup < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :batch
  belongs_to :grouped_exam

  has_many :exams, :dependent => :destroy
  before_destroy :removable?
  belongs_to :cce_exam_category

  accepts_nested_attributes_for :exams

  attr_accessor :maximum_marks, :minimum_marks, :weightage
  validates_associated :exams

  validates_uniqueness_of :cce_exam_category_id, :scope=>:batch_id, :message=>"already assigned for another Exam Group",:unless => lambda { |e| e.cce_exam_category_id.nil?}
  
  def removable?
    self.exams.reject{|e| e.removable?}.empty?
  end

  def before_save
    self.exam_date = self.exam_date || Date.today 
  end

  def before_validation
    if self.exam_type.downcase == "grades"
      self.exams.each do |ex|
        ex.maximum_marks = 0
        ex.minimum_marks = 0
      end
    end
  end

  def batch_average_marks(marks)
    batch = self.batch
    exams = self.exams
    batch_students = batch.students
    total_students_marks = 0
    #   total_max_marks = 0
    students_attended = []
    exams.each do |exam|
      batch_students.each do |student|
        exam_score = ExamScore.find_by_student_id_and_exam_id(student.id,exam.id)
        unless exam_score.nil?
          unless exam_score.marks.nil?
            total_students_marks = total_students_marks+exam_score.marks
            unless students_attended.include? student.id
              students_attended.push student.id
            end
          end
        end
      end
      #      total_max_marks = total_max_marks+exam.maximum_marks
    end
    unless students_attended.size == 0
      batch_average_marks = total_students_marks/students_attended.size
    else
      batch_average_marks = 0
    end
    return batch_average_marks if marks == 'marks'
    #   return total_max_marks if marks == 'percentage'
  end

  def weightage
    grp = GroupedExam.find_by_batch_id_and_exam_group_id(self.batch.id,self.id)
    unless grp.nil?
      weight = grp.weightage
    else
      weight=0
    end
    return weight
  end

  def archived_batch_average_marks(marks)
    batch = self.batch
    exams = self.exams
    batch_students = ArchivedStudent.find_all_by_batch_id(self.batch.id)
    total_students_marks = 0
    #   total_max_marks = 0
    students_attended = []
    exams.each do |exam|
      batch_students.each do |student|
        exam_score = ArchivedExamScore.find_by_student_id_and_exam_id(student.id,exam.id)
        unless exam_score.nil?
          unless exam_score.marks.nil?
            total_students_marks = total_students_marks+exam_score.marks
            unless students_attended.include? student.id
              students_attended.push student.id
            end
          end
        end
      end
      #      total_max_marks = total_max_marks+exam.maximum_marks
    end
    unless students_attended.size == 0
      batch_average_marks = total_students_marks/students_attended.size
    else
      batch_average_marks = 0
    end
    return batch_average_marks if marks == 'marks'
  end

  def batch_average_percentage
    
  end

  def subject_wise_batch_average_marks(subject_id)
    batch = self.batch
    subject = Subject.find(subject_id)
    exam = Exam.find_by_exam_group_id_and_subject_id(self.id,subject.id)
    batch_students = batch.students
    total_students_marks = 0
    #   total_max_marks = 0
    students_attended = []

    batch_students.each do |student|
      exam_score = ExamScore.find_by_student_id_and_exam_id(student.id,exam.id)
      unless exam_score.nil?
        total_students_marks = total_students_marks+ (exam_score.marks || 0)
        unless students_attended.include? student.id
          students_attended.push student.id
        end
      end
    end
    #      total_max_marks = total_max_marks+exam.maximum_marks
    unless students_attended.size == 0
      subject_wise_batch_average_marks = total_students_marks/students_attended.size.to_f
    else
      subject_wise_batch_average_marks = 0
    end
    return subject_wise_batch_average_marks
    #   return total_max_marks if marks == 'percentage'
  end

  def total_marks(student)
    exams = Exam.find_all_by_exam_group_id(self.id)
    total_marks = 0
    max_total = 0
    exams.each do |exam|
      exam_score = ExamScore.find_by_exam_id_and_student_id(exam.id,student.id)
      total_marks = total_marks + (exam_score.marks || 0) unless exam_score.nil?
      max_total = max_total + exam.maximum_marks unless exam_score.nil?
    end
    result = [total_marks,max_total]
  end

  def archived_total_marks(student)
    exams = Exam.find_all_by_exam_group_id(self.id)
    total_marks = 0
    max_total = 0
    exams.each do |exam|
      exam_score = ArchivedExamScore.find_by_exam_id_and_student_id(exam.id,student.id)
      total_marks = total_marks + (exam_score.marks || 0 ) unless exam_score.nil?
      max_total = max_total + exam.maximum_marks unless exam_score.nil?
    end
    result = [total_marks,max_total]
  end

  def course
    batch.course if batch
  end

end