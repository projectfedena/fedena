class AddMarksToClassDesignations < ActiveRecord::Migration
  def self.up
    add_column :class_designations, :marks, :decimal, :precision=>15, :scale=>2
  end

  def self.down
    remove_column :class_designations, :marks
  end
end
