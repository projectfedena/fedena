class CreateEmployeeGrades < ActiveRecord::Migration
  def self.up
    create_table :employee_grades do |t|
      t.string :name
      t.integer :priority
      t.boolean :status
      t.integer :max_hours_day
      t.integer :max_hours_week
    end
  end

  def self.down
    drop_table :employee_grades
  end
end
