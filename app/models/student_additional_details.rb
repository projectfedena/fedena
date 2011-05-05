class StudentAdditionalDetails < ActiveRecord::Base
  belongs_to :student
  belongs_to :student_additional_field
end
