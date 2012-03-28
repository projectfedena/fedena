class AddRemarkToMonthlyPayslip < ActiveRecord::Migration
  def self.up
    add_column :monthly_payslips, :remark, :string
  end

  def self.down
    remove_column :monthly_payslips, :remark
  end
end
