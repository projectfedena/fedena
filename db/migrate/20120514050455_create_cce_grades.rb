class CreateCceGrades < ActiveRecord::Migration
  def self.up
    create_table :cce_grades do |t|
      t.string    :name
      t.float     :grade_point
      t.integer   :cce_grade_set_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cce_grades
  end
end
