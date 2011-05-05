class CreateIndividualPayslipCategories < ActiveRecord::Migration
  def self.up
    create_table :individual_payslip_categories do |t|
      t.references :employee
      t.date       :salary_date
      t.string     :name
      t.string     :amount
      t.boolean    :is_deduction
      t.boolean    :include_every_month
    end
  end

  def self.down
    drop_table :individual_payslip_categories
  end
end
