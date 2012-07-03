class CreateCceReports < ActiveRecord::Migration
  def self.up
    create_table :cce_reports do |t|
      t.integer       :observable_id
      t.string        :observable_type
      t.integer       :student_id
      t.integer       :batch_id
      t.string        :grade_string
      t.timestamps
    end
  end

  def self.down
    drop_table :cce_reports
  end
end
