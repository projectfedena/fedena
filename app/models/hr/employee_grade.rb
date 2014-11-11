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
class EmployeeGrade < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :priority
  validates_numericality_of :priority

  has_many :employee
  named_scope :active, :conditions => {:status => true }
  validate :max_hours_week_should_be_greater_than_max_hours_day

  private
  def max_hours_week_should_be_greater_than_max_hours_day
    if self.max_hours_day && self.max_hours_week && self.max_hours_day > self.max_hours_week
      self.errors.add(:max_hours_week, "#{t('should_be_greater_than_max_period')}.")
    end
  end
end
