class CreateGradingLevels < ActiveRecord::Migration
  def self.up
    create_table :grading_levels do |t|
      t.string     :name
      t.references :batch
      t.integer    :min_score
      t.integer    :order
      t.boolean    :is_deleted, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :grading_levels
  end

end
