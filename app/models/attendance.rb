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

class Attendance < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch

  validates_presence_of   :reason, :month_date, :batch_id, :student_id
  validates_uniqueness_of :student_id, :scope => [:month_date], :message => "already marked as absent"
  named_scope             :by_month, lambda { |d| { :conditions => { :month_date => d.beginning_of_month..d.end_of_month } } }
  named_scope             :by_month_and_batch, lambda { |d, b| { :conditions => { :month_date => d.beginning_of_month..d.end_of_month, :batch_id => b } } }
  validate                :student_current_batch, :valid_month_date

  def full_day?
    forenoon? && afternoon?
  end

  def half_day?
    forenoon? || afternoon?
  end

  private

    def student_current_batch 
      errors.add('batch_id', "attendance is not marked for present batch") if student && student.batch_id != batch_id
    end

    def valid_month_date
      errors.add("#{t('attendance_before_the_date_of_admission')}")  if month_date && student && month_date < student.admission_date
    end
end