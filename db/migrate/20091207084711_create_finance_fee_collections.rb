class CreateFinanceFeeCollections < ActiveRecord::Migration
  def self.up
    create_table :finance_fee_collections do |t|
      t.string     :name
      t.date       :start_date
      t.date       :end_date
      t.date       :due_date
      t.references :fee_category
      t.references :batch
      t.boolean    :is_deleted, :null => false, :default => false
    end
  end

  def self.down
    drop_table :finance_fee_collections
  end
end
