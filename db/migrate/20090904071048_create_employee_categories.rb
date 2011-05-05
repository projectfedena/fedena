class CreateEmployeeCategories < ActiveRecord::Migration
  def self.up
    create_table :employee_categories do |t|
      t.string :name
      t.string :prefix
      t.boolean :status
    end
    create_default
  end

  def self.down
    drop_table :employee_categories
  end

   def self.create_default
     EmployeeCategory.create :name => 'Fedena Admin',:prefix => 'Admin',:status => true
  end
end
