class AddColumnsToWeekdays < ActiveRecord::Migration
  def self.up
    add_column :weekdays, :name, :string
    add_column :weekdays, :sort_order, :integer
    add_column :weekdays, :day_of_week, :integer

  end

  def self.down
    remove_column :weekdays, :name
    remove_column :weekdays, :sort_order
    remove_column :weekdays, :day_of_week
  end
end
