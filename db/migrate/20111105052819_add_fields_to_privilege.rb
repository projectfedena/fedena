class AddFieldsToPrivilege < ActiveRecord::Migration
  def self.up
     #add_column :privileges, :description, :text
    Privilege.all.each do |privilege|
      privilege.update_attributes(:description=> privilege.name.underscore+"_privilege")
    end
  end

  def self.down
    remove_column :privileges, :description
  end
end
