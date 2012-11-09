class AddIsMandatoryAndInputTypeToStudentAdditionalFields < ActiveRecord::Migration
  def self.up
    add_column :student_additional_fields, :is_mandatory, :boolean, :default=>false
    add_column :student_additional_fields, :input_type, :string
  end

  def self.down
    remove_column :student_additional_fields, :input_type
    remove_column :student_additional_fields, :is_mandatory
  end
end
