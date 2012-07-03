class AddCceEnabledToCourses < ActiveRecord::Migration
  def self.up
    add_column  :courses,:cce_enabled,:boolean
  end

  def self.down
    remove_column  :courses,:cce_enabled
  end
end
