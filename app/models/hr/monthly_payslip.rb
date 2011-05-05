class MonthlyPayslip < ActiveRecord::Base

  validates_presence_of :salary_date

  belongs_to :payroll_category
  belongs_to :employee
  belongs_to :approver ,:class_name => 'User'
  belongs_to :rejector ,:class_name => 'User'

  def approve(user_id)
    self.is_approved = true
    self.approver_id = user_id
    self.save
  end

  def reject(user_id, reason)
    self.is_rejected = true
    self.rejector_id = user_id
    self.reason = reason
    self.save
  end

  def payslip_count(start_date,end_date)
    
  end


end
