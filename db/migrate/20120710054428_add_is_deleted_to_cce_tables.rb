class AddIsDeletedToCceTables < ActiveRecord::Migration
  def self.up
    add_column  :observation_groups,  :is_deleted,  :boolean,:default=>false
    add_column  :fa_criterias,  :is_deleted,  :boolean,:default=>false
    add_column  :fa_groups,  :is_deleted,  :boolean,:default=>false
  end

  def self.down
    remove_column  :observation_groups,  :is_deleted
    remove_column  :fa_criterias,  :is_deleted
    remove_column  :fa_groups,  :is_deleted
  end
end
