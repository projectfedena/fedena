class CreateEmployeesSubjects < ActiveRecord::Migration
  def self.up
    create_table :employees_subjects do |t|
      t.references :employee
      t.references :subject
    end
  end

  def self.down
    drop_table :employees_subjects
  end
end
