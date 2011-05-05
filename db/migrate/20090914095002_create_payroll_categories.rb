class CreatePayrollCategories < ActiveRecord::Migration
  def self.up
    create_table :payroll_categories do |t|
      t.string :name
      t.float  :percentage
      t.references :payroll_category
      t.boolean :is_deduction
      t.boolean :status
    end
  end

  def self.down
    drop_table :payroll_categories
  end
end
