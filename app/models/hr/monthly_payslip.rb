# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class MonthlyPayslip < ActiveRecord::Base

  validates_presence_of :salary_date

  belongs_to :payroll_category
  belongs_to :employee
  belongs_to :approver ,:class_name => 'User'
  belongs_to :rejector ,:class_name => 'User'

  def approve(user_id, remark)
    self.is_approved = true
    self.approver_id = user_id
    self.remark = remark
    self.save
  end

  def reject(user_id, reason)
    self.is_rejected = true
    self.rejector_id = user_id
    self.reason = reason
    self.save
  end

  def self.find_and_filter_by_department(salary_date, dept_id)
    payslips = ""
    individual_payslip_category = ""
    if dept_id != "All"
      active_employees_in_dept = Employee.find(:all, :select => "id", :conditions => ["employee_department_id = ?", dept_id])
      archived_employees_in_dept = ArchivedEmployee.find(:all, :select => "former_id", :conditions => ["employee_department_id = ?", dept_id])
      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect{|a| a.former_id.to_i}
      payslips = self.find_all_by_salary_date(salary_date.to_date, :conditions => ["employee_id IN (?)", all_employees_in_dept], :order => "payroll_category_id ASC", :include => [:payroll_category])
      individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(salary_date.to_date, :conditions => ["employee_id IN (?)", all_employees_in_dept], :order => "id ASC")
    else
      payslips = self.find_all_by_salary_date(salary_date.to_date, :order => "payroll_category_id ASC", :include => [:payroll_category])
      individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(salary_date.to_date, :order => "id ASC")
    end
    grouped_monthly_payslips = payslips.group_by(&:employee_id) if payslips.present?
    grouped_individual_payslip_categories = individual_payslip_category.group_by(&:employee_id) if individual_payslip_category.present?
    { :monthly_payslips => grouped_monthly_payslips, :individual_payslip_category => grouped_individual_payslip_categories }
  end

  def active_or_archived_employee
    employee = Employee.find(:first, :conditions => ["id = ?", self.employee_id])
    archived_employee = ArchivedEmployee.find(:first, :conditions => ["former_id = ?", self.employee_id])
    employee.present? ? employee : archived_employee
  end

  def status_as_text
    is_approved ? "#{t('approved')}" : is_rejected ? "#{t('rejected')}" : "#{t('pending')}"
  end


  def self.total_employees_salary(start_date, end_date, dept_id = "")
    total_monthly_payslips  = ""
    if dept_id.present?
      active_employees_in_dept = Employee.find(:all, :select => "id", :conditions => ["employee_department_id = ?", dept_id])
      archived_employees_in_dept = ArchivedEmployee.find(:all, :select => "former_id", :conditions => ["employee_department_id = ?", dept_id])
      all_employees_in_dept = active_employees_in_dept.collect(&:id) + archived_employees_in_dept.collect{|a| a.former_id.to_i}
      total_monthly_payslips = self.find(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1 and employee_id IN (?)", start_date.to_date, end_date.to_date, all_employees_in_dept], :include => [:payroll_category])
    else
      total_monthly_payslips = self.find(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1", start_date.to_date, end_date.to_date], :include => [:payroll_category])
    end

    employee_ids = []
    total_individual_payslips = []
    employee_ids = total_monthly_payslips.collect(&:employee_id) if total_monthly_payslips.any?
    if employee_ids.any?
      total_individual_payslips = IndividualPayslipCategory.find(:all, :conditions => ["salary_date >= ? and salary_date <= ? AND employee_id IN (?)", start_date.to_date, end_date.to_date, employee_ids.uniq.join(",")], :order => "id ASC")
    end
    total_salary = 0
    if total_monthly_payslips.any?
      total_monthly_payslips.each do |payslip|
        payslip.payroll_category.is_deduction? ? total_salary -= payslip.amount.to_f : total_salary += payslip.amount.to_f
      end
    end
    if total_individual_payslips.any?
      total_individual_payslips.each do |payslip|
        payslip.is_deduction? ? total_salary -= payslip.amount.to_f : total_salary += payslip.amount.to_f
      end
    end
    {:total_salary => total_salary, :monthly_payslips => total_monthly_payslips, :individual_categories => total_individual_payslips}
  end


end
