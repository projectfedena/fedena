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
  
end
