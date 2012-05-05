class AddBatchIdToAttendanceAndSubjectLeave < ActiveRecord::Migration
  def self.up
    add_column :attendances, :batch_id, :integer
    add_column :subject_leaves, :batch_id, :integer
  end

  def self.down
    remove_column :attendances, :batch_id
    remove_column :subject_leaves, :batch_id
  end
end
