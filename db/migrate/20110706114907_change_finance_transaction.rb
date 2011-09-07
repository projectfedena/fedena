class ChangeFinanceTransaction < ActiveRecord::Migration
  def self.up
    change_column :finance_transactions, :fine_amount, :decimal,:precision => 10, :scale => 2
  end

  def self.down
  end
end
