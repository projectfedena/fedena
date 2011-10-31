class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :config_key
      t.string :config_value
    end
    create_default
  end

  def self.down
    drop_table :configurations
  end

  def self.create_default
    Configuration.create :config_key => "InstitutionName", :config_value => ""
    Configuration.create :config_key => "InstitutionAddress", :config_value => ""
    Configuration.create :config_key => "InstitutionPhoneNo", :config_value => ""
    Configuration.create :config_key => "StudentAttendanceType", :config_value => "Daily"
    Configuration.create :config_key => "CurrencyType", :config_value => "$"
    Configuration.create :config_key => "Locale", :config_value=>"en"
    #Configuration.create :config_key => "ExamResultType", :config_value => "Marks"
    Configuration.create :config_key => "AdmissionNumberAutoIncrement", :config_value => "1"
    Configuration.create :config_key => "EmployeeNumberAutoIncrement", :config_value => "1"
    Configuration.create :config_key => "TotalSmsCount", :config_value=>"0"
    Configuration.create :config_key => "AvailableModules", :config_value=>"HR"
    Configuration.create :config_key => "AvailableModules", :config_value=>"Finance"


  end

end