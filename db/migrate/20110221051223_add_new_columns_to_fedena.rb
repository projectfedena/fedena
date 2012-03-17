class AddNewColumnsToFedena < ActiveRecord::Migration
  def self.up
    add_column :students,  :has_paid_fees, :boolean, :default => false
    add_column :batches,  :employee_id, :string
    change_column :student_categories,  :is_deleted, :boolean,:null => false, :default => false
    change_column :exams, :maximum_marks, :decimal,:precision => 10, :scale => 2
    change_column :exams, :minimum_marks, :decimal,:precision => 10, :scale => 2
    rename_column :timetable_entries, :week_day_id, :weekday_id
    add_column :monthly_payslips, :is_rejected, :boolean, :null => false, :default => false
    add_column :monthly_payslips, :rejector_id, :integer
    add_column :monthly_payslips, :reason, :string
    add_column :employee_leave_types, :carry_forward ,:boolean, :null => false, :default=>false
    change_column :finance_transactions, :amount, :decimal, :precision =>15, :scale => 2
    add_column :finance_transactions, :transaction_date, :date
    add_column :finance_transactions, :fine_amount, :decimal, :default =>0
    add_column :finance_transactions, :master_transaction_id, :integer, :default =>0
    #add_column :finance_transactions, :user_id, :integer
    change_column :finance_donations, :amount, :decimal, :precision =>15, :scale => 2
    add_column :finance_donations, :transaction_date, :date
    change_column :finance_fees, :transaction_id, :string
    change_column :finance_fee_structure_elements, :amount, :decimal, :precision =>15, :scale => 2
    change_column :finance_fee_particulars, :amount, :decimal, :precision =>15, :scale => 2
  end

  def self.down
    remove_column :students,  :has_paid_fees
    remove_column :batches,  :employee_id
    remove_column :monthly_payslips, :is_rejected
    remove_column :monthly_payslips, :rejector_id
    remove_column :monthly_payslips, :reason
    remove_column :employee_leave_types, :carry_forward
    remove_column :finance_transactions, :transaction_date
    remove_column :finance_transactions, :fine_amount
    remove_column :finance_transactions, :master_transaction_id

    remove_column :finance_donations, :transaction_date
  end

end
