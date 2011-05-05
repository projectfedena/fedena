class CreateCoursesAndBatches < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string     :course_name
      t.string     :code
      t.string     :section_name
      t.boolean    :is_deleted, :default => false
      t.timestamps
    end

    create_table :batches do |t|
      t.string     :name
      t.references :course
      t.datetime   :start_date
      t.datetime   :end_date
      t.boolean    :is_active, :default => true
      t.boolean    :is_deleted, :default => false
    end
  end

  def self.down
    drop_table :batches
    drop_table :courses
  end

end
