class FixColumnNameTableBach < ActiveRecord::Migration
  def self.up
    change_column :batches, :start_date, :date
    rename_column :batches, :start_date, :started_on

    change_column :batches, :end_date, :date
    rename_column :batches, :end_date, :ended_on
  end

  def self.down
  end
end
