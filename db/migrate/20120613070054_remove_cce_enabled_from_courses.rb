class RemoveCceEnabledFromCourses < ActiveRecord::Migration
  def self.up
    remove_column :courses, :cce_enabled
  end

  def self.down
    add_column :courses, :cce_enabled, :boolean
  end
end
