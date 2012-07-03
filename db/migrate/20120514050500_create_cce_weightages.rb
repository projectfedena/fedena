class CreateCceWeightages < ActiveRecord::Migration
  def self.up
    create_table :cce_weightages do |t|
      t.integer     :weightage
      t.string      :criteria_type
      t.integer     :cce_exam_category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cce_weightages
  end
end
