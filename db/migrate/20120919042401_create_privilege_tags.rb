class CreatePrivilegeTags < ActiveRecord::Migration
  def self.up
    create_table :privilege_tags do |t|
      t.string :name_tag
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :privilege_tags
  end
end
