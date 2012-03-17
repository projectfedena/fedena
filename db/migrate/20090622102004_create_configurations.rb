class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :config_key
      t.string :config_value
    end
  end

  def self.down
    drop_table :configurations
  end

end
