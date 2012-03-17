class CreateWeekdays < ActiveRecord::Migration
  def self.up
    create_table :weekdays do |t|
      t.references :batch
      t.string :weekday
    end
  end

  def self.down
    drop_table :weekdays
  end

end
