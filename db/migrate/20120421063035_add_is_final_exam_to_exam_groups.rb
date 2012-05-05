class AddIsFinalExamToExamGroups < ActiveRecord::Migration
  def self.up
    add_column :exam_groups, :is_final_exam, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :exam_groups, :is_final_exam
  end
end
