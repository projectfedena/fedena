class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name
    end
    create_default
  end

  def self.down
    drop_table :countries
  end
end
