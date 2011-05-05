class StudentsSubject < ActiveRecord::Migration
  def self.up
    create_table :students_subjects do |t|
      t.references :student
      t.references :subject
      t.references :batch
    end
  end

  def self.down
    drop_table :students_subjects
  end
end
