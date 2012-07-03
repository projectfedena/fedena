class CreateDescriptiveIndicators < ActiveRecord::Migration
  def self.up
    create_table :descriptive_indicators do |t|
      t.string        :name
      t.string        :desc
      t.integer       :describable_id
      t.string        :describable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :descriptive_indicators
  end
end
