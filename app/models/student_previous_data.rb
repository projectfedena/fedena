class StudentPreviousData < ActiveRecord::Base
  belongs_to :student
  validates_presence_of :institution
end
