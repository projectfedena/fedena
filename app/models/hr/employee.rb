class Employee < ActiveRecord::Base
  belongs_to  :employee_category
  belongs_to  :employee_position
  belongs_to  :employee_grade
  belongs_to  :employee_department
  belongs_to  :nationality, :class_name => 'Country'
  has_and_belongs_to_many :subjects
  has_many    :timetable_entries
  has_many    :employee_bank_details
  has_many    :employee_additional_details
  has_many    :apply_leaves
  has_many    :monthly_payslips
  has_many    :employee_salary_structures
  before_update :validate_updation
  validates_format_of     :email, :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,   :allow_blank=>true,
    :message => "must be a valid email address"

  validates_presence_of :employee_category_id, :employee_number, :first_name, :employee_position_id,
    :employee_department_id, :employee_grade_id, :date_of_birth
  validates_uniqueness_of  :employee_number

  before_save :user_validation

  def user_validation
    if self.id.nil?
      if User.find_by_username("#{self.employee_number}")
        errors.add_to_base( "User already exist with entered Employee number")
        return false
      end
    else
      employee = Employee.find(self.id)
      if User.find_by_username("#{employee.employee_number}", :conditions=>["id != #{employee.user.id}"])
        errors.add_to_base( "User already exist with entered Employee number")
        return false
      end
    end
  end

  def image_file=(input_data)
    return if input_data.blank?
    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end

  def max_hours_per_day
    self.employee_grade.max_hours_day
  end

  def max_hours_per_week
    self.employee_grade.max_hours_week
  end

  def user
    User.find_by_username self.employee_number
  end

  def next_employee
    next_st = self.employee_department.employees.first(:conditions => "id>#{self.id}",:order => "id ASC")
    next_st ||= employee_department.employees.first(:order => "id ASC")
    next_st ||= self.employee_department.employees.first(:order => "id ASC")
  end

  def previous_employee
    prev_st = self.employee_department.employees.first(:conditions => "id<#{self.id}",:order => "id DESC")
    prev_st ||= employee_department.employees.first(:order => "id DESC")
    prev_st ||= self.employee_department.empoyees.first(:order => "id DESC")
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def is_payslip_approved(date)
    approve = MonthlyPayslip.find_all_by_salary_date_and_employee_id(date,self.id,:conditions => ["is_approved = true"])
    if approve.empty?
      return false
    else
      return true
    end
  end
  def is_payslip_rejected(date)
    approve = MonthlyPayslip.find_all_by_salary_date_and_employee_id(date,self.id,:conditions => ["is_rejected = true"])
    if approve.empty?
      return false
    else
      return true
    end
  end

  def self.total_employees_salary(employees,start_date,end_date)
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

    monthly_payslips = MonthlyPayslip.find(:all,
      :order => 'salary_date desc',
      :conditions => ["employee_id ='#{self.id}'and salary_date = '#{salary_date}' and is_approved = 1"])
    individual_payslip_category = IndividualPayslipCategory.find(:all,
      :order => 'salary_date desc',
      :conditions => ["employee_id ='#{self.id}'and salary_date >= '#{salary_date}'"])
    individual_category_non_deductionable = 0
    individual_category_deductionable = 0
    individual_payslip_category.each do |pc|
      unless pc.is_deduction == true
        individual_category_non_deductionable = individual_category_non_deductionable + pc.amount.to_f
      end
    end

    individual_payslip_category.each do |pc|
      unless pc.is_deduction == false
        individual_category_deductionable = individual_category_deductionable + pc.amount.to_f
      end
    end

    non_deductionable_amount = 0
    deductionable_amount = 0
    monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      unless category1.is_deduction == true
        non_deductionable_amount = non_deductionable_amount + mp.amount.to_f
      end
    end

    monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      unless category2.is_deduction == false
        deductionable_amount = deductionable_amount + mp.amount.to_f
      end
    end
    net_non_deductionable_amount = individual_category_non_deductionable + non_deductionable_amount
    net_deductionable_amount = individual_category_deductionable + deductionable_amount

    net_amount = net_non_deductionable_amount - net_deductionable_amount
    return net_amount.to_f
  end


  def salary(start_date,end_date)
    MonthlyPayslip.find_by_employee_id(self.id,:order => 'salary_date desc',
      :conditions => ["salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' and is_approved = 1"]).salary_date

  end

  def archive_employee(status)
    self.update_attributes(:status => false, :status_description => status)
    employee_attributes = self.attributes
    employee_attributes.delete "id"
    if archived_employee = ArchivedEmployee.create(employee_attributes)
      user = User.find_by_username(self.employee_number).delete unless user.nil?
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
      self.delete
    end
  end
 

  def all_salaries(start_date,end_date)
    MonthlyPayslip.find_all_by_employee_id(self.id,:select =>"distinct salary_date" ,:order => 'salary_date desc',
      :conditions => ["salary_date >= '#{start_date.to_date}' and salary_date <= '#{end_date.to_date}' and is_approved = 1"])
  end

  def validate_updation
    employee = Employee.find(self.id)
    unless self.email.blank?
      user = User.find_by_email(self.email, :conditions=>["id != #{employee.user.id}"])
      unless user.nil?
        errors.add(:email, "already taken")
      end
    else
      self.email = "noreply#{self.employee_number}@fedena.com"
    end

    user = User.find_by_username(self.employee_number.to_s, :conditions=>["id != #{employee.user.id}"])
    unless user.nil?
      errors.add_to_base( "User already exist with entered employee number")
    end
    return false if !errors.blank?
  end
end
