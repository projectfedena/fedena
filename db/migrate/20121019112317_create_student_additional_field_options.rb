class CreateStudentAdditionalFieldOptions < ActiveRecord::Migration
  def self.up
    create_table :student_additional_field_options do |t|
      t.integer :student_additional_field_id
      t.string :field_option

      t.timestamps
    end
  end

  def self.down
    drop_table :student_additional_field_options
  end
end
