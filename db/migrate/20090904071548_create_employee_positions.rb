class CreateEmployeePositions < ActiveRecord::Migration
  def self.up
    create_table :employee_positions do |t|
      t.string  :name
      t.references :employee_category
      t.boolean :status
    end
    create_default
  end

  def self.down
    drop_table :employee_positions
  end

  def self.create_default
    EmployeePosition.create :name => 'Fedena Admin',:employee_category_id => 1,:status => true
  end
end
