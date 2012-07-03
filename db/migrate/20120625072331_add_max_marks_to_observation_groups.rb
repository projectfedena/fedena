class AddMaxMarksToObservationGroups < ActiveRecord::Migration
  def self.up
    add_column :observation_groups, :max_marks, :float
  end

  def self.down
    remove_column :observation_groups, :max_marks
  end
end
