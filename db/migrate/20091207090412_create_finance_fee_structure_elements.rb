class CreateFinanceFeeStructureElements < ActiveRecord::Migration
  def self.up
    create_table :finance_fee_structure_elements do |t|
      t.decimal    :amount, :precision => 12, :scale => 2
      t.string     :label
      t.references :batch
      t.references :student_category
      t.references :student
      t.references :parent
      t.references :fee_collection
      t.boolean    :deleted, :default => false
    end
  end

  def self.down
    drop_table :finance_fee_structure_elements
  end
end
