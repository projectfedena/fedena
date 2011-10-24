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
  belongs_to :subject
  belongs_to :student
  belongs_to :period_entry, :foreign_key => :period_table_entry_id
  validates_uniqueness_of :student_id, :scope => [:period_table_entry_id]
  validates_presence_of :reason

  def validate
    errors.add("#{t('attendance_before_the_date_of_admission')}")  if self.period_entry.month_date < self.student.admission_date
  end
end
