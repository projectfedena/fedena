class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :username
      t.string   :first_name
      t.string   :last_name
      t.string   :email

      t.boolean  :admin
      t.boolean  :student
      t.boolean  :employee
      
      t.string   :hashed_password
      t.string   :salt
      t.string   :reset_password_code
      t.datetime :reset_password_code_until
      
      t.timestamps
    end
    create_default
  end

  def self.down
    drop_table :users
  end

  def self.create_default
    User.create :username   => 'admin',:password   => 'admin123',:first_name => 'Fedena',
    :last_name  => 'Administrator',:email=> 'admin@fedena.com',:role=> 'Admin'
  end


end
