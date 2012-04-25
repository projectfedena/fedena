class AddUserColumnToGuardian < ActiveRecord::Migration
  def self.up
    add_column  :guardians ,:user_id,:integer
  end

  def self.down
    remove_column   :guardians ,:user_id
  end
end
