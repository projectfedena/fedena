class AddCceGradeSetToFaGroups < ActiveRecord::Migration
  def self.up
    add_column      :fa_groups,   :cce_grade_set_id,    :integer
  end

  def self.down
    remove_column      :fa_groups,   :cce_grade_set_id
  end
end
