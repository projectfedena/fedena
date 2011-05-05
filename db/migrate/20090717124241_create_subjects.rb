class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string     :name
      t.string     :code
      t.references :batch
      t.boolean    :no_exams, :default=>false
      t.integer    :max_weekly_classes
      t.references :elective_group
      t.boolean    :is_deleted, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :subjects
  end

end
