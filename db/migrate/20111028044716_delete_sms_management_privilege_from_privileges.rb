class DeleteSmsManagementPrivilegeFromPrivileges < ActiveRecord::Migration
  def self.up
    @privilege = Privilege.find_by_name("SMSManagement")
    @privilege.destroy
  end

  def self.down
  end
end
