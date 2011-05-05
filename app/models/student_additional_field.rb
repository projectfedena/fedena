class StudentAdditionalField < ActiveRecord::Base
  belongs_to :student
  belongs_to :student_additional_details
  validates_presence_of :name
  validates_uniqueness_of :name,:case_sensitive => false
end
