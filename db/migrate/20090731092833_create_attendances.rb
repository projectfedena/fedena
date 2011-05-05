class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.references :student
      t.references :period_table_entry
      t.boolean :forenoon, :default => false
      t.boolean :afternoon, :default => false
      t.string :reason
    end
  end

  def self.down
    drop_table :attendances
  end
end
