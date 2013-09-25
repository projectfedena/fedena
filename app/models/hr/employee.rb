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
class Employee < ActiveRecord::Base
  belongs_to  :employee_category
  belongs_to  :employee_position
  belongs_to  :employee_grade
  belongs_to  :employee_department
  belongs_to  :nationality, :class_name => 'Country'
  belongs_to  :user
  belongs_to  :reporting_manager,:class_name => "Employee"

  has_many    :employees_subjects
  has_many    :subjects ,:through => :employees_subjects
  has_many    :timetable_entries
  has_many    :employee_bank_details
  has_many    :employee_additional_details
  has_many    :apply_leaves
  has_many    :monthly_payslips
  has_many    :employee_salary_structures
  has_many    :finance_transactions, :as => :payee
  has_many    :employee_attendances

  validates_format_of     :email, :with => /\A[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i,   :allow_blank=>true,
    :message => "#{t('must_be_a_valid_email_address')}"

  validates_presence_of :employee_category_id, :employee_number, :first_name, :employee_position_id,
    :employee_department_id,  :date_of_birth, :joining_date, :nationality_id
  validates_uniqueness_of  :employee_number

  validates_associated :user
  before_validation :create_user_and_validate
  before_save :status_true
  has_attached_file :photo,
    :styles => {:original=> "125x125#"},
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  VALID_IMAGE_TYPES = ['image/gif', 'image/png','image/jpeg', 'image/jpg']

  validates_attachment_content_type :photo, :content_type =>VALID_IMAGE_TYPES,
    :message=>'Image can only be GIF, PNG, JPG',:if=> Proc.new { |p| !p.photo_file_name.blank? }
  validates_attachment_size :photo, :less_than => 512000,\
    :message=>'must be less than 500 KB.',:if=> Proc.new { |p| p.photo_file_name_changed? }

  def status_true
    self.status = true if self.status == false
  end

  def create_user_and_validate
    if self.new_record?
      user_record = self.build_user
      user_record.first_name = self.first_name
      user_record.last_name = self.last_name
      user_record.username = self.employee_number.to_s
      user_record.password = self.employee_number.to_s + "123"
      user_record.role = 'Employee'
      user_record.email = self.email.blank? ? "" : self.email.to_s
      check_user_errors(user_record)
    else
      changes_to_be_checked = ['employee_number','first_name','last_name','email']
      check_changes = self.changed & changes_to_be_checked
      #      self.user.role ||= "Employee"
      if check_changes.any?
        emp_user = self.user
        emp_user.username = self.employee_number.to_s if check_changes.include?('employee_number')
        emp_user.password = self.employee_number.to_s + "123" if check_changes.include?('employee_number')
        emp_user.first_name = self.first_name if check_changes.include?('first_name')
        emp_user.last_name = self.last_name if check_changes.include?('last_name')
        emp_user.email = self.email.to_s if check_changes.include?('email')
        emp_user.save if check_user_errors(self.user)
      end
    end
  end

  def check_user_errors(user)
    unless user.valid?
      user.errors.each{ |attr,msg| errors.add(attr.to_sym,"#{msg}") }
    end
    user.errors.blank?
  end

  def employee_batches
    batches_with_employees = Batch.active.reject{ |b| b.employee_id.nil? }
    assigned_batches = batches_with_employees.reject{ |e| !e.employee_id.split(",").include?(self.id.to_s) }
    return assigned_batches
  end

  def image_file=(input_data)
    return if input_data.blank?
    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end

  def max_hours_per_day
    self.employee_grade.max_hours_day unless self.employee_grade.blank?
  end

  def max_hours_per_week
    self.employee_grade.max_hours_week unless self.employee_grade.blank?
  end
  alias_method(:max_hours_day, :max_hours_per_day)
  alias_method(:max_hours_week, :max_hours_per_week)

  def next_employee
    next_st = self.employee_department.employees.first(:conditions => ["id > ?", self.id], :order => "id ASC")
    next_st ||= self.employee_department.employees.first(:order => "id ASC")
  end

  def previous_employee
    prev_st = self.employee_department.employees.first(:conditions => ["id < ?", self.id], :order => "id DESC")
    prev_st ||= self.employee_department.employees.first(:order => "id DESC")
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def payslip_approved?(date)
    MonthlyPayslip.find_all_by_salary_date_and_employee_id_and_is_approved(date, self.id, true).any?
  end

  def payslip_rejected?(date)
    MonthlyPayslip.find_all_by_salary_date_and_employee_id_and_is_rejected(date, self.id, true).any?
  end

  def self.total_employees_salary(employees, start_date, end_date)
    salary = 0
    employees.each do |e|
      salary_dates = e.all_salaries(start_date,end_date)
      salary_dates.each do |s|
        salary += e.employee_salary(s.salary_date.to_date)
      end
    end
    salary
  end

  def employee_salary(salary_date)
    monthly_payslips = MonthlyPayslip.find(:all, :order => 'salary_date desc', :conditions => ["employee_id = ? AND salary_date = ? AND is_approved = ?", self.id, salary_date, true])
    individual_payslip_category = IndividualPayslipCategory.find(:all, :order => 'salary_date desc', :conditions => ["employee_id = ? AND salary_date >= ?", self.id, salary_date])
    individual_category_non_deductionable = 0
    individual_category_deductionable = 0
    individual_payslip_category.each do |pc|
      if pc.is_deduction?
        individual_category_deductionable = individual_category_deductionable + pc.amount.to_f
      else
        individual_category_non_deductionable = individual_category_non_deductionable + pc.amount.to_f
      end
    end

    non_deductionable_amount = 0
    deductionable_amount = 0
    monthly_payslips.each do |mp|
      category = PayrollCategory.find(mp.payroll_category_id)
      if category.is_deduction?
        deductionable_amount = deductionable_amount + mp.amount.to_f
      else
        non_deductionable_amount = non_deductionable_amount + mp.amount.to_f
      end
    end

    net_non_deductionable_amount = individual_category_non_deductionable + non_deductionable_amount
    net_deductionable_amount = individual_category_deductionable + deductionable_amount

    net_non_deductionable_amount - net_deductionable_amount
  end


  def salary(start_date, end_date)
    MonthlyPayslip.find_by_employee_id(self.id, :order => 'salary_date desc', :conditions => ["salary_date >= ? AND salary_date <= ? and is_approved = ?", start_date.to_date, end_date.to_date, true]).salary_date
  end

  def archive_employee(status)
    self.update_attributes(:status_description => status)
    employee_attributes = self.attributes
    employee_attributes.delete "id"
    employee_attributes.delete "photo_file_size"
    employee_attributes.delete "photo_file_name"
    employee_attributes.delete "photo_content_type"
    employee_attributes["former_id"] = self.id
    archived_employee = ArchivedEmployee.new(employee_attributes)
    archived_employee.photo = self.photo
    if archived_employee.save
      #      self.user.delete unless self.user.nil?
      employee_salary_structures = self.employee_salary_structures
      employee_bank_details = self.employee_bank_details
      employee_additional_details = self.employee_additional_details
      employee_salary_structures.each do |g|
        g.archive_employee_salary_structure(archived_employee.id)
      end
      employee_bank_details.each do |g|
        g.archive_employee_bank_detail(archived_employee.id)
      end
      employee_additional_details.each do |g|
        g.archive_employee_additional_detail(archived_employee.id)
      end
      self.user.soft_delete
      self.destroy
    end
  end


  def all_salaries(start_date, end_date)
    MonthlyPayslip.find_all_by_employee_id(self.id, :select =>"distinct salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = ?", start_date.to_date, end_date.to_date, true])
  end

  def self.calculate_salary(monthly_payslip, individual_payslip_category)
    individual_category_non_deductionable = 0
    individual_category_deductionable = 0

    individual_payslip_category.each do |pc|
      if pc.is_deduction?
        individual_category_deductionable = individual_category_deductionable + pc.amount.to_f
      else
        individual_category_non_deductionable = individual_category_non_deductionable + pc.amount.to_f
      end
    end

    non_deductionable_amount = 0
    deductionable_amount = 0

    monthly_payslip.each do |mp|
      if mp.payroll_category.present?
        if mp.payroll_category.is_deduction?
          deductionable_amount = deductionable_amount + mp.amount.to_f
        else
          non_deductionable_amount = non_deductionable_amount + mp.amount.to_f
        end
      end
    end

    net_non_deductionable_amount = individual_category_non_deductionable + non_deductionable_amount
    net_deductionable_amount = individual_category_deductionable + deductionable_amount
    net_amount = net_non_deductionable_amount - net_deductionable_amount

    {:net_amount => net_amount, :net_deductionable_amount => net_deductionable_amount, :net_non_deductionable_amount => net_non_deductionable_amount }
  end

  def self.find_in_active_or_archived(id)
    Employee.find_by_id(id) || ArchivedEmployee.find_by_id(id)
  end

  def has_dependency
    self.monthly_payslips.present? || self.employee_salary_structures.present? || self.employees_subjects.present? \
      || self.apply_leaves.present? || self.finance_transactions.present? || self.timetable_entries.present? \
      || self.employee_attendances.present? || FedenaPlugin.check_dependency(self,"permanant").present?
  end

  def former_dependency
    FedenaPlugin.check_dependency(self,"former")
  end

end
