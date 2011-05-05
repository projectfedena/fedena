class CreateEmployeeLeaveTypes < ActiveRecord::Migration
  def self.up
    create_table :employee_leave_types do |t|
      t.string   :name
      t.string   :code
      t.boolean  :status
      t.string   :max_leave_count
    end
  end

  def self.down
    drop_table :employee_leave_types
  end
end
