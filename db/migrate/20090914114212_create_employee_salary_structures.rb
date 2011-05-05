class CreateEmployeeSalaryStructures < ActiveRecord::Migration
  def self.up
    create_table :employee_salary_structures do |t|
      t.references :employee
      t.references :payroll_category
      t.string     :amount
    end
  end

  def self.down
    drop_table :employee_salary_structures
  end
end
