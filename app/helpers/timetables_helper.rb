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
module TimetablesHelper
  def subject_code(tte)
    if tte && tte.subject.present?
      "#{tte.subject.code}\n"
    end
  end

  def subject_name(tte)
    if tte && tte.subject.present?
      "#{tte.subject.name}\n"
    end
  end

  def elective_subject_code(tte, emp)
    if tte && tte.subject.present?
      if tte.subject.elective_group.present?
        sub = tte.subject.elective_group.subjects.select { |s| s.employees.include?(emp) }
        "#{sub.first.code}\n" unless sub.empty?
      else
        "#{tte.subject.code}\n"
      end
    end
  end

  def timetable_batch(tte)
    if tte && tte.batch.present?
      "#{tte.batch.full_name}"
    end
  end

  def employee_name(tte)
    if tte && tte.employee.present?
      "#{tte.employee.first_name}"
    end
  end

  def employee_full_name(tte)
    if tte && tte.employee.present?
      "#{tte.employee.full_name}"
    end
  end
end