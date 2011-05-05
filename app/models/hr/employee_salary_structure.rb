class EmployeeSalaryStructure < ActiveRecord::Base
  belongs_to :payroll_category
  belongs_to :employee

  def archive_employee_salary_structure(archived_employee)
    salary_structure_attributes = self.attributes
    salary_structure_attributes.delete "id"
    salary_structure_attributes["employee_id"] = archived_employee
    self.delete if ArchivedEmployeeSalaryStructure.create(salary_structure_attributes)
  end

end
