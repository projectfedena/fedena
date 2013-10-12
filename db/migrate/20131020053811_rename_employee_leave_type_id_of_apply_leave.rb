class RenameEmployeeLeaveTypeIdOfApplyLeave < ActiveRecord::Migration
  def self.up
    rename_column :apply_leaves, :employee_leave_types_id, :employee_leave_type_id
  end

  def self.down
    rename_column :apply_leaves, :employee_leave_type_id, :employee_leave_types_id
  end
end
