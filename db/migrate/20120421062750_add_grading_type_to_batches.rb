class AddGradingTypeToBatches < ActiveRecord::Migration
  def self.up
    add_column :batches, :grading_type, :string
  end

  def self.down
    remove_column :batches, :grading_type
  end
end
