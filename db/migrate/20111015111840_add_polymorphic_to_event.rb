class AddPolymorphicToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :origin_id,  :integer
    add_column :events, :origin_type,  :string
  end

  def self.down
    remove_column :events, :origin_id,  :integer
    remove_column :events, :origin_type,  :string
  end
end
