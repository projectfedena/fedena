class AddUserIdToArchivedStudents < ActiveRecord::Migration
  def self.up
    add_column :archived_students, :user_id, :integer
  end

  def self.down
    remove_column :archived_students, :user_id
  end
end
