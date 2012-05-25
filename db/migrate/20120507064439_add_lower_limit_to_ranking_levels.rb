class AddLowerLimitToRankingLevels < ActiveRecord::Migration
  def self.up
    add_column :ranking_levels, :lower_limit, :boolean, :default=>false
  end

  def self.down
    remove_column :ranking_levels, :lower_limit
  end
end
