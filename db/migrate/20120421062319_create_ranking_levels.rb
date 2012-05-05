class CreateRankingLevels < ActiveRecord::Migration
  def self.up
    create_table :ranking_levels do |t|
      t.string :name, :null => false
      t.decimal :gpa, :precision => 15, :scale => 2
      t.decimal :marks, :precision => 15, :scale => 2
      t.integer :subject_count
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :ranking_levels
  end
end
