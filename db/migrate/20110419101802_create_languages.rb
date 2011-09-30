class CreateLanguages < ActiveRecord::Migration
   def self.up
    create_table :languages do |t|
      t.string :name
      t.string :code

    end
    create_default
  end

  def self.down
    drop_table :languages
  end

  def self.create_default
    Language.create :name   => 'English',:code =>'en'
    Language.create :name   => 'Spanish',:code =>'es'
  end
end
