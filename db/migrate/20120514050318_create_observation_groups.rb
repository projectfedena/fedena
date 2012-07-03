class CreateObservationGroups < ActiveRecord::Migration
  def self.up
    create_table :observation_groups do |t|
      t.string        :name
      t.string        :header_name
      t.string        :desc
      t.string        :cce_grade_set_id
      t.timestamps
    end
  end

  def self.down
    drop_table :observation_groups
  end
end
