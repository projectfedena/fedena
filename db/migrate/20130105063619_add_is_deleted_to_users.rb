class AddIsDeletedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_deleted, :boolean,:default=>false
  end

  def self.down
    remove_column :users, :is_deleted
  end
end
