class CreateEmployeeGrades < ActiveRecord::Migration
  def self.up
    create_table :employee_grades do |t|
      t.string :name
      t.integer :priority
      t.boolean :status
      t.integer :max_hours_day
      t.integer :max_hours_week
    end
       create_default
  end

  def self.down
    drop_table :employee_grades
  end

    def self.create_default
    EmployeeGrade.create :name => 'Fedena Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil
  end
end
