class CreatePrivilegesUsersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :privileges_users, :id => false do |t|
      t.references(:user)
      t.references(:privilege)
    end
  end

  def self.down
    drop_table :privileges_users
  end
end
