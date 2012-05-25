class AddAmountToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :amount, :decimal, :precision=>15, :scale=>2
  end

  def self.down
    remove_column :subjects, :amount
  end
end
