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

class Attendance < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch

  validates_presence_of :reason,:month_date,:batch_id,:student_id
  validates_uniqueness_of :student_id, :scope => [:month_date],:message=>"already marked as absent"
  named_scope :by_month, lambda { |d| { :conditions  => { :month_date  => d.beginning_of_month..d.end_of_month } } }
  named_scope :by_month_and_batch, lambda { |d,b| {:conditions  => { :month_date  => d.beginning_of_month..d.end_of_month,:batch_id=>b } } }
  #validate :student_current_batch

  def validate
    unless self.student.nil?
      if self.student.batch_id == self.batch_id
        return true
      else
        errors.add('batch_id',"attendance is not marked for present batch")
        return false
      end
    end
  end

  def after_validate
    unless self.month_date.nil?
      errors.add("#{t('attendance_before_the_date_of_admission')}")  if self.student.present? and self.month_date < self.student.admission_date
    else
      errors.add("#{t('month_date_cant_be_blank')}")
    end
  end

  def is_full_day
    forenoon == true and afternoon == true
  end

  def is_half_day
    forenoon == true or afternoon == true
  end
 
end