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
