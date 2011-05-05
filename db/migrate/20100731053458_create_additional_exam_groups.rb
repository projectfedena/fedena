class CreateAdditionalExamGroups < ActiveRecord::Migration
  def self.up
    create_table :additional_exam_groups do |t|
      t.string     :name
      t.references :batch
      t.string     :exam_type
      t.boolean    :is_published, :default=>false
      t.boolean    :result_published, :default=>false
      t.string :students_list
      t.date       :exam_date
    end
  end
  
  def self.down
    drop_table :additional_exam_groups
  end
end
