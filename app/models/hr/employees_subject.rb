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
class EmployeesSubject < ActiveRecord::Base
  belongs_to :employee
  belongs_to :subject
  has_one :batch, :through => :subject

  def self.allot_work(subject_employee_ids)
    status = true
    employee_assignments = {}

    subject_employee_ids.each do |subject_id, employee_id|
      employee_assignments[employee_id] ||= []
      employee_assignments[employee_id] << subject_id
    end

    transaction do
      employee_assignments.each do |employee_id, subject_ids|
        if employee_overloaded?(employee_id, subject_ids)
          status = false
          raise ActiveRecord::Rollback
        end

        subject_ids.each do |subject_id|
          es = self.find_or_initialize_by_employee_id_and_subject_id(:subject_id => subject_id, :employee_id => employee_id)
          if !es.save
            status = false
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    status
  end

  def self.employee_overloaded?(employee_id, subject_ids)
    employee = Employee.find(employee_id)
    subjects = Subject.find(subject_ids)
    assigned_hrs = subjects.sum { |s| s.max_weekly_classes } || 0
    max_hrs      = employee.max_hours_per_week || 0

    assigned_hrs > max_hrs
  end
end
