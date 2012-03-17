class AddFieldsToPrivilege < ActiveRecord::Migration
  def self.up
    add_column :privileges, :description, :text
  end

  def self.down
    remove_column :privileges, :description
  end
end
