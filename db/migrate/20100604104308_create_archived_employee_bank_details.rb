class CreateArchivedEmployeeBankDetails < ActiveRecord::Migration
  def self.up
    create_table :archived_employee_bank_details do |t|
      t.references :employee
      t.references :bank_field
      t.string      :bank_info
    end
  end

  def self.down
    drop_table :archived_employee_bank_details
  end
end
