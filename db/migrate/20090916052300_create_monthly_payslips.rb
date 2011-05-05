class CreateMonthlyPayslips < ActiveRecord::Migration
  def self.up
    create_table :monthly_payslips do |t|
      t.date     :salary_date
      t.references :employee
      t.references :payroll_category
      t.string     :amount
      t.boolean   :is_approved,:null => false, :default => false
      t.references   :approver
      
    end
  end

  def self.down
    drop_table :monthly_payslips
  end
end
