class AddUserIdToStudentsEmployees < ActiveRecord::Migration
  def self.up
    add_column :students,:user_id,:integer
    add_column :employees,:user_id,:integer
    execute "UPDATE students SET user_id = (SELECT id from users WHERE username = students.admission_no)"
    execute "UPDATE employees SET user_id = (SELECT id from users WHERE username = employees.employee_number)"
  end

  def self.down
    remove_column :students,:user_id
    remove_column :employees,:user_id
  end
end
