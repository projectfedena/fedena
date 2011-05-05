class CreateStudentAdditionalDetails < ActiveRecord::Migration
  def self.up
    create_table :student_additional_details do |t|
      t.references :student
      t.references :additional_field
      t.string     :additional_info
    end
  end

  def self.down
    drop_table :student_additional_details
  end
end