class RemoveGradingTypeFromBatches < ActiveRecord::Migration
  def self.up
	remove_column :batches, :grading_type
  end

  def self.down
	add_column :batches, :grading_type, :string
  end
end
