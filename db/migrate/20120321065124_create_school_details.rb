class CreateSchoolDetails < ActiveRecord::Migration
  def self.up
    create_table :school_details do |t|
      t.integer :school_id
      t.string :logo_file_name
      t.string :logo_content_type
      t.string :logo_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :school_details
  end

end
