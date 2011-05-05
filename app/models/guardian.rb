class Guardian < ActiveRecord::Base
  belongs_to :country
  belongs_to :ward, :class_name => 'Student'

  validates_presence_of :first_name, :relation

  def validate
    errors.add(:dob, "cannot be a future date.") if self.dob > Date.today unless self.dob.nil?
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
