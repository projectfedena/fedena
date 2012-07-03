class CreateCceGradeSets < ActiveRecord::Migration
  def self.up
    create_table :cce_grade_sets do |t|
      t.string      :name
      t.timestamps
    end
  end

  def self.down
    drop_table :cce_grade_sets
  end
end
