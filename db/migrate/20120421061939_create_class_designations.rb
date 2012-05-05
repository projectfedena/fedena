class CreateClassDesignations < ActiveRecord::Migration
  def self.up
    create_table :class_designations do |t|
      t.string :name, :null => false
      t.decimal :cgpa, :precision => 15, :scale => 2

      t.timestamps
    end
  end

  def self.down
    drop_table :class_designations
  end
end
