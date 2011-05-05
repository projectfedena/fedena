class CreateExams < ActiveRecord::Migration
  def self.up
    create_table :exams do |t|
      t.references :exam_group
      t.references :subject
      t.datetime   :start_time
      t.datetime   :end_time
      t.decimal    :maximum_marks,:precision => 10, :scale => 2
      t.decimal    :minimum_marks,:precision => 10, :scale => 2
      t.references :grading_level
      t.integer    :weightage, :default => 0

      t.references :event
      t.timestamps
    end
  end

  def self.down
    drop_table :exams
  end

end
