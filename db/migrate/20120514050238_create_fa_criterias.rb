class CreateFaCriterias < ActiveRecord::Migration
  def self.up
    create_table :fa_criterias do |t|
      t.string  :fa_name
      t.string  :desc
      t.integer :fa_group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fa_criterias
  end
end
