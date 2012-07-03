class CreateCceWeightagesCourses < ActiveRecord::Migration
    def self.up
    create_table :cce_weightages_courses, :id => false do |t|
      t.integer     :cce_weightage_id
      t.integer     :course_id
    end
  end

  def self.down
    drop_table  :cce_weightages_courses
  end
end
