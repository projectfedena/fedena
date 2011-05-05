class CreateFinanceFees < ActiveRecord::Migration
  def self.up
    create_table :finance_fees do |t|
      t.references :fee_collection
      t.string :transaction_id
      t.references :student
    end
  end

  def self.down
    drop_table :finance_fees
  end
end
