class CreateElectives < ActiveRecord::Migration
  def self.up
    create_table :electives do |t|
      t.references :elective_group
      t.timestamps
    end
  end

  def self.down
    drop_table :electives
  end
end
