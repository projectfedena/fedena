class EmployeeAttendance < ActiveRecord::Base
  validates_presence_of :employee_leave_type_id, :reason
  validates_uniqueness_of :employee_id, :scope=> :attendance_date
  belongs_to :employee
  belongs_to :employee_leave_type
  before_save :validate

  def validate
     if self.attendance_date.to_date < self.employee.joining_date.to_date
     errors.add(:employee_attendance,"Date marked is earlier than joining date ")
    end
  end
  
end
