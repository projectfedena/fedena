class CreateFinanceFeeParticulars < ActiveRecord::Migration
  def self.up
    create_table :finance_fee_particulars do |t|
      t.string      :name
      t.text        :description
      t.decimal     :amount, :precision => 12, :scale => 2
      t.references  :finance_fee_category
      t.references  :student_category
      t.string      :admission_no
      t.references  :student
      t.boolean     :is_deleted, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :finance_fee_particulars
  end
end
