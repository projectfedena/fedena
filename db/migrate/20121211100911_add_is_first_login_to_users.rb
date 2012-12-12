class AddIsFirstLoginToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_first_login, :boolean
  end

  def self.down
    remove_column :users, :is_first_login
  end
end
