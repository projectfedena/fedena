class CreateArchivedEmployeeSalaryStructures < ActiveRecord::Migration
  def self.up
    create_table :archived_employee_salary_structures do |t|
      t.references :employee
      t.references :payroll_category
      t.string     :amount
    end
  end

  def self.down
    drop_table :archived_employee_salary_structures
  end
end
