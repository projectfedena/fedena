class CreateSubjectAmounts < ActiveRecord::Migration
  def self.up
    create_table :subject_amounts do |t|
      t.references :course
      t.decimal :amount
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :subject_amounts
  end
end
