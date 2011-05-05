class EmployeeGrade < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :priority
  validates_numericality_of :priority
  has_many :employee
  named_scope :active, :conditions => {:status => true }
end
