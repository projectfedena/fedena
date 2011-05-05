class EmployeeCategory < ActiveRecord::Base
  validates_presence_of :name, :prefix
  validates_uniqueness_of :name, :prefix
  named_scope :active, :conditions => {:status => true }
  has_many :employee_positions
  belongs_to :employee_salary_structure
  has_many :employee
end
