class CreateFaGroupsSubjects < ActiveRecord::Migration
  def self.up
    create_table :fa_groups_subjects, :id => false do |t|
      t.integer     :subject_id
      t.integer     :fa_group_id
    end
  end

  def self.down
    drop_table  :fa_groups_subjects
  end
end
