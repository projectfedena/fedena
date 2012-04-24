class AddParentColumnToUser < ActiveRecord::Migration
  def self.up
    add_column  :users ,:parent , :boolean
  end

  def self.down
    remove_column   :users ,:parent
  end
end
