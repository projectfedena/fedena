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

class Guardian < ActiveRecord::Base
  belongs_to :country
  belongs_to :ward, :class_name => 'Student'
  belongs_to :user,:dependent=>:destroy, :autosave =>true

  validates_presence_of :first_name, :relation

  def validate
    errors.add(:dob, "#{t('cant_be_a_future_date')}.") if self.dob > Date.today unless self.dob.nil?
  end

  def is_immediate_contact?
    ward.immediate_contact_id == id
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def archive_guardian(archived_student)
    guardian_attributes = self.attributes
    guardian_attributes.delete "id"
    guardian_attributes["ward_id"] = archived_student
    self.delete if ArchivedGuardian.create(guardian_attributes)
  end

  def create_guardian_user
    user = User.new do |u|
      u.first_name = self.first_name
      u.last_name = self.last_name
      u.username = "p"+self.ward.admission_no.to_s
      u.password = "p#{self.ward.admission_no.to_s}123"
      u.role = 'Parent'
      u.email = ( email == '' or User.find_by_email(self.email) ) ? "noreplyp#{self.ward.admission_no.to_s}@fedena.com" :self.email.to_s
    end
    user.save
  end

 

  def self.shift_user(student)
    self.find_all_by_ward_id(student.id).each do |g|
      parent_user = g.user
      parent_user.destroy if parent_user.present?
    end
    current_guardian =  student.immediate_contact
    current_guardian.create_guardian_user if  current_guardian.present?
  end

  
end
