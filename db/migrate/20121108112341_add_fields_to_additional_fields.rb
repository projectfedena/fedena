class AddFieldsToAdditionalFields < ActiveRecord::Migration
  def self.up
	add_column :additional_fields, :is_mandatory, :boolean, :default=>false
    add_column :additional_fields, :input_type, :string
	add_column :additional_fields, :priority, :integer
  end

  def self.down
	remove_column :additional_fields, :input_type
    remove_column :additional_fields, :is_mandatory
	remove_column :additional_fields, :priority
  end
end
