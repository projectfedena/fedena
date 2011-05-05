class CreateWeekdays < ActiveRecord::Migration
  def self.up
    create_table :weekdays do |t|
      t.references :batch
      t.string :weekday
    end
     create_default
  end

  def self.down
    drop_table :weekdays
  end

  def self.create_default
   Weekday.create :batch_id=>"", :weekday=>"1"
   Weekday.create :batch_id=>"", :weekday=>"2"
   Weekday.create :batch_id=>"", :weekday=>"3"
   Weekday.create :batch_id=>"", :weekday=>"4"
   Weekday.create :batch_id=>"", :weekday=>"5"
  end

end
