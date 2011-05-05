class CreateApplyLeaves < ActiveRecord::Migration
  def self.up
    create_table :apply_leaves do |t|
      t.references  :employee
      t.references  :employee_leave_types
      t.boolean     :is_half_day
      t.date        :start_date
      t.date        :end_date
      t.string      :reason
      t.boolean     :approved, :default => false
      t.boolean     :viewed_by_manager, :default => false
      t.string      :manager_remark
    end
  end

  def self.down
    drop_table :apply_leaves
  end
end
