class CreateEmployeeAdditionalDetails < ActiveRecord::Migration
  def self.up
    create_table :employee_additional_details do |t|
      t.references :employee
      t.references :additional_field
      t.string     :additional_info
    end
  end

  def self.down
    drop_table :employee_additional_details
  end
end
