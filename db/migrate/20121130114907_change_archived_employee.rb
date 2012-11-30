class ChangeArchivedEmployee < ActiveRecord::Migration
  def self.up
    change_column :archived_employees, :gender, :string
  end

  def self.down
  #change_column :employees, :gender, :boolean
  end
end
