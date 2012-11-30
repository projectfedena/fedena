class ChangeEmployee < ActiveRecord::Migration
  def self.up
    change_column :employees, :gender, :string
  end

  def self.down
  #change_column :employees, :gender, :boolean
  end
end
