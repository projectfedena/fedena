class CreateFinanceDonations < ActiveRecord::Migration
  def self.up
    create_table :finance_donations do |t|
      t.string     :donor
      t.string     :description
      t.decimal    :amount, :precision => 15, :scale => 2
      t.references :transaction
      t.timestamps
    end
  end

  def self.down
    drop_table :finance_donations
  end
end
