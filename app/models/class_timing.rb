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

class ClassTiming < ActiveRecord::Base
  has_many :timetable_entries, :dependent=>:destroy
  belongs_to :batch

  validates_presence_of :name
  validates_uniqueness_of :name,  :scope => [:batch_id , :is_deleted]

  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted=>false, :is_break => false},  :order =>'start_time ASC' } }
  named_scope :default, :conditions => { :batch_id => nil, :is_break => false, :is_deleted=>false  }, :order =>'start_time ASC'
  named_scope :active_for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted=>false},  :order =>'start_time ASC' } }
  named_scope :active, :conditions => { :batch_id => nil, :is_deleted=>false  }, :order =>'start_time ASC'

  def validate
    errors.add(:end_time, "#{t('should_be_later')}.") \
      if self.start_time > self.end_time \
      unless self.start_time.nil? or self.end_time.nil?
    self_check= self.new_record? ? "" : "id != #{self.id} and "
    start_overlap = !ClassTiming.find(:first, :conditions=>[self_check+"start_time < ? and end_time > ? and is_deleted = ? and batch_id #{self.batch_id.nil? ? 'is null' : '='+ self.batch_id.to_s}", self.start_time,self.start_time,false]).nil?
    end_overlap = !ClassTiming.find(:first, :conditions=>[self_check+"start_time < ? and end_time > ? and is_deleted = ? and batch_id #{self.batch_id.nil? ? 'is null' : '='+ self.batch_id.to_s}", self.end_time,self.end_time,false]).nil?
    between_overlap = !ClassTiming.find(:first, :conditions=>[self_check+"start_time < ? and end_time > ? and is_deleted = ? and batch_id #{self.batch_id.nil? ? 'is null' : '='+ self.batch_id.to_s}",self.end_time, self.start_time,false]).nil?
    errors.add(:start_time, "#{t('overlap_existing_class_timing')}.") if start_overlap
    errors.add(:end_time, "#{t('overlap_existing_class_timing')}.") if end_overlap
    errors.add_to_base("#{t('class_time_overlaps_with_existing')}.") if between_overlap
    errors.add(:start_time,"#{t('is_same_as_end_time')}") if self.start_time == self.end_time
  end
end
