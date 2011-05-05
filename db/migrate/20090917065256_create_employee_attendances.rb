class CreateEmployeeAttendances < ActiveRecord::Migration
  def self.up
    create_table :employee_attendances do |t|
      t.date       :attendance_date
      t.references :employee
      t.references :employee_leave_type
      t.string     :reason
      t.boolean    :is_half_day
    end
  end

  def self.down
    drop_table :employee_attendances
  end
end
