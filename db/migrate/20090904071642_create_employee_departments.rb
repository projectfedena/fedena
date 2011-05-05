class CreateEmployeeDepartments < ActiveRecord::Migration
  def self.up
    create_table :employee_departments do |t|
      t.string  :code
      t.string  :name
      t.boolean :status
    end
   create_default
  end

  def self.down
    drop_table :employee_departments
  end

  def self.create_default
    EmployeeDepartment.create :code => 'Admin',:name => 'Fedena Admin',:status => true
  end
end
