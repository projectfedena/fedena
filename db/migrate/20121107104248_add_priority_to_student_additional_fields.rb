class AddPriorityToStudentAdditionalFields < ActiveRecord::Migration
  def self.up
    add_column :student_additional_fields, :priority, :integer
  end

  def self.down
    remove_column :student_additional_fields, :priority
  end
end
