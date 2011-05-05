class ApplyLeave < ActiveRecord::Base
  validates_presence_of :employee_leave_types_id, :start_date, :end_date, :reason
  belongs_to :employee
  belongs_to :employee_leave_type
  before_create :check_leave_count
  
  cattr_reader :per_page
  @@per_page = 12

  def check_leave_count
    unless self.start_date.nil? or self.end_date.nil?
      errors.add_to_base(" End date can't be before start date") if self.end_date < self.start_date
    end
    unless self.start_date.nil? or self.end_date.nil? or self.employee_leave_types_id.nil?
      leave = EmployeeLeave.find_by_employee_id(self.employee_id, :conditions=> "employee_leave_type_id = '#{self.employee_leave_types_id}'")
      leave_required = (self.end_date.to_date-self.start_date.to_date).numerator+1
      if self.start_date.to_date < self.employee.joining_date.to_date
        errors.add_to_base(" Date marked is before join date ")
      else
        if leave.leave_taken.to_f == leave.leave_count.to_f
          errors.add_to_base("You have already availed all available leave ")
        else
          if self.is_half_day == true
            new_leave_count = (leave_required)/2
            if leave.leave_taken.to_f+new_leave_count.to_f > leave.leave_count.to_f
              errors.add_to_base("No of leaves exeeds maximum allowed leaves")
            end
          else
            new_leave_count = leave_required.to_f
            if leave.leave_taken.to_f+new_leave_count.to_f > leave.leave_count.to_f
              errors.add_to_base("No of leaves exeeds maximum allowed leaves")
            end
          end
        end
      end
    end
  end
end
