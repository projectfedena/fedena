class AddCreditHoursToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :credit_hours, :decimal, :precision => 15, :scale => 2
    add_column :subjects, :prefer_consecutive, :boolean, :default => false
  end

  def self.down
    remove_column :subjects, :prefer_consecutive
    remove_column :subjects, :credit_hours
  end
end
