class AddFieldsToPrivilege < ActiveRecord::Migration
  def self.up
    add_column :privileges, :description, :text
    Privilege.all.each do |privilege|
      execute("UPDATE privileges SET `description`='#{privilege.name.underscore+"_privilege"}' WHERE `name` = '#{privilege.name}'")
    end
  end

  def self.down
    remove_column :privileges, :description
  end
end
