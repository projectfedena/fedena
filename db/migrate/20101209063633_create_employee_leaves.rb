class CreateEmployeeLeaves < ActiveRecord::Migration
  def self.up
    create_table :employee_leaves do |t|
      t.references :employee
      t.references :employee_leave_type
      t.decimal    :leave_count ,:precision => 5, :scale => 1, :default => 0
      t.decimal    :leave_taken ,:precision => 5, :scale => 1, :default => 0
      t.date       :reset_date
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_leaves
  end
end
