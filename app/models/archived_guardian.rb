class ArchivedGuardian < ActiveRecord::Base
  belongs_to :country
  belongs_to :ward, :class_name => 'ArchivedStudent'



  def full_name
    "#{first_name} #{last_name}"
  end

  def is_immediate_contact?
    ward.immediate_contact_id == id
  end
end