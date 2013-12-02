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
class EmployeeLeave < ActiveRecord::Base
  belongs_to :employee_leave_type

  def self.reset_all
    EmployeeLeave.all.each(&:reset)
  end

  def reset
    calculate_leave_days if employee_leave_type.status
  end

  def calculate_leave_days
    default_leave_count = employee_leave_type.max_leave_count
    if employee_leave_type.carry_forward && self.leave_taken <= self.leave_count
      self.leave_count -= self.leave_taken
      self.leave_count += default_leave_count.to_f
    else
      self.leave_count = default_leave_count.to_f
    end
    self.leave_taken = 0
    self.reset_date = Date.today
    self.save
  end

  def update_leave_taken_by(is_half_day)
    self.leave_taken += is_half_day ? 0.5 : 1
    self.save
  end
end
