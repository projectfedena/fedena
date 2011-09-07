class AddColumnsToEmployee < ActiveRecord::Migration
    def self.up
        add_column    :archived_employees, :photo_file_size, :integer
        rename_column :archived_employees, :photo_filename, :photo_file_name
        add_column    :employees, :photo_file_size, :integer
        rename_column :employees, :photo_filename, :photo_file_name

    end

    def self.down
        remove_column :archived_employees, :photo_file_size
        rename_column :archived_employees, :photo_file_name, :photo_filename
        remove_column :employees, :photo_file_size
        rename_column :employees, :photo_file_name, :photo_filename
    end
end
