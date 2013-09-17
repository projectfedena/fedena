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
class Weekday < ActiveRecord::Base

  WEEKDAYS = {
    '0' => I18n.t('sunday'),
    '1' => I18n.t('monday'),
    '2' => I18n.t('tuesday'),
    '3' => I18n.t('wednesday'),
    '4' => I18n.t('thursday'),
    '5' => I18n.t('friday'),
    '6' => I18n.t('saturday')
  }

  belongs_to :batch
  has_many :timetable_entries , :dependent => :destroy

  default_scope :order => 'weekday ASC'
  named_scope   :default, :conditions => { :batch_id => nil, :is_deleted => false }
  named_scope   :for_batch, lambda { |b| { :conditions => { :batch_id => b, :is_deleted => false } } }

  def self.weekday_by_day(batch_id)
    weekdays = Weekday.find_all_by_batch_id(batch_id)
    weekdays = Weekday.default if weekdays.empty?

    weekdays.group_by(&:day_of_week)
  end

  def deactivate
    self.update_attribute(:is_deleted, true)
  end

  def self.add_day(batch_id, day)
    batch_id = nil if batch_id == 0

    if weekday = Weekday.find_by_batch_id_and_day_of_week(batch_id, day)
      weekday.update_attributes(:is_deleted => false, :day_of_week => day)
    else
      Weekday.create(:day_of_week => day, :weekday => day, :batch_id => batch_id, :is_deleted => false)
    end
  end
end
