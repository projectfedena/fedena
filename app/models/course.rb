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

class Course < ActiveRecord::Base
  validates_presence_of :course_name, :code
  validate :presence_of_initial_batch, :on => :create

  has_many :batches
  accepts_nested_attributes_for :batches

  named_scope :active, :conditions => { :is_deleted => false }, :order => 'course_name asc'
  named_scope :deleted, :conditions => { :is_deleted => true }, :order => 'course_name asc'

  def presence_of_initial_batch
    errors.add_to_base "#{t('should_have_an_initial_batch')}" if batches.length == 0
  end

  def inactivate
    update_attribute(:is_deleted, true)
  end
  
  def full_name
    "#{course_name} #{section_name}"
  end

#  def guardian_email_list
#    email_addresses = []
#    students = self.students
#    students.each do |s|
#      email_addresses << s.immediate_contact.email unless s.immediate_contact.nil?
#    end
#    email_addresses
#  end
#
#  def student_email_list
#    email_addresses = []
#    students = self.students
#    students.each do |s|
#      email_addresses << s.email unless s.email.nil?
#    end
#    email_addresses
#  end

end