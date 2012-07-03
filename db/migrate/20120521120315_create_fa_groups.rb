class CreateFaGroups < ActiveRecord::Migration
  def self.up
    create_table :fa_groups do |t|
      t.string      :name
      t.text        :desc
      t.integer     :cce_exam_category_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fa_groups
  end
end
