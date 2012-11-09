class CreateAdditionalFieldOptions < ActiveRecord::Migration
  def self.up
    create_table :additional_field_options do |t|
      t.integer :additional_field_id
      t.string :field_option
      t.integer :school_id

      t.timestamps
    end
  end

  def self.down
    drop_table :additional_field_options
  end
end
