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
class ClassTiming < ActiveRecord::Base
  has_many :timetable_entries, :dependent => :destroy
  belongs_to :batch

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:batch_id , :is_deleted]

  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted => false, :is_break => false },  :order =>'start_time ASC' } }
  named_scope :default, :conditions => { :batch_id => nil, :is_break => false, :is_deleted => false }, :order => 'start_time ASC'
  named_scope :active_for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted => false }, :order => 'start_time ASC'} }
  named_scope :active, :conditions => { :batch_id => nil, :is_deleted => false }, :order => 'start_time ASC'
  validate :end_date_is_later_than_start_date, :start_time_same_end_time, :check_start_overlap, :check_between_overlap, :check_end_overlap

  private

  def overlap_condition(first_time, second_time)
    self_check = new_record? ? '' : "id != #{self.id} AND "
    self_batch_id = batch_id.nil? ? 'batch_id IS NULL' : 'batch_id = ' + batch_id.to_s
    start_date_and_end_date_exists? && !!ClassTiming.find(:first, :conditions => [self_check + self_batch_id + " AND start_time < ? AND end_time > ? AND is_deleted = ?", first_time, second_time, false])
  end

  def start_date_and_end_date_exists?
    start_time && end_time
  end

  def end_date_is_later_than_start_date
    errors.add(:end_time, "#{t('should_be_later')}.") if start_date_and_end_date_exists? && start_time > end_time
  end

  def start_time_same_end_time
    errors.add(:start_time,"#{t('is_same_as_end_time')}") if start_date_and_end_date_exists? && start_time == end_time
  end

  def check_start_overlap
    errors.add(:start_time, "#{t('overlap_existing_class_timing')}.") if overlap_condition(start_time, start_time)
  end

  def check_between_overlap
    errors.add_to_base("#{t('class_time_overlaps_with_existing')}.") if overlap_condition(end_time, start_time)
  end

  def check_end_overlap
    errors.add(:end_time, "#{t('overlap_existing_class_timing')}.") if overlap_condition(end_time, end_time)
  end
end
