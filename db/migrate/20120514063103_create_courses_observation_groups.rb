class CreateCoursesObservationGroups < ActiveRecord::Migration
  def self.up
    create_table :courses_observation_groups, :id => false do |t|
      t.integer     :course_id
      t.integer     :observation_group_id
    end
  end

  def self.down
    drop_table  :courses_observation_groups
  end
end
