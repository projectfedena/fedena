class ChangeCreditPointsToDecimal < ActiveRecord::Migration
  def self.up
	change_column :grading_levels, :credit_points, :decimal, :precision=>15, :scale=>2
  end

  def self.down
	change_column :grading_levels, :credit_points, :integer
  end
end
