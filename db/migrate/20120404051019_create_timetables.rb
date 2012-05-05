class CreateTimetables < ActiveRecord::Migration
  def self.up
    create_table :timetables do |t|
      t.date     :start_date
      t.date     :end_date
      t.boolean      :is_active,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :timetables
  end
end
