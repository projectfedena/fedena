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
    Configuration.create :config_key   => 'Locale',:config_value =>'en'
    Language.create :name   => 'Spanish',:code =>'es'
    Configuration.create :config_key   => 'Locale',:config_value =>'es'
  end
end
