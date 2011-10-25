class AddIsPaidToFinanceFees < ActiveRecord::Migration
  def self.up
    add_column :finance_fees, :is_paid, :boolean, :default => false
  end

  def self.down
    remove_column :finance_fees, :is_paid
  end
end
