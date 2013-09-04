require 'spec_helper'

describe Configuration do

  context 'configuration' do

    CONFIG_HASH ={"InstitutionName"=>"School Name",
      "InstitutionAddress" => "School Address",
      "InstitutionPhoneNo" => "Phone",
      "StudentAttendanceType" => "Daily",
      "CurrencyType"  => "Rs.",
      "AdmissionNumberAutoIncrement"  => "0",
      "EmployeeNumberAutoIncrement"  => "1",
      "TotalSmsCount"  => "133",
      "AvailableModules"  => "HR",
      "AvailableModules"  => "Finance",
      "AvailableModules"  => "SMS",
      "NetworkState"  => "Online",
      "FinancialYearStartDate"  => "2011-06-1",
      "FinancialYearEndDate"  => "2012-05-30",
      "AutomaticLeaveReset"  => "0",
      "LeaveResetPeriod"  => "4",
      "LastAutoLeaveReset"  => ""
    }

    before do
      CONFIG_HASH.each do |key,value|
        Configuration.create(:config_key=>key,:config_value=>value)
      end
    end
    CONFIG_HASH.each do |key,value|
      it "should be able to get config value for #{key}" do
        config_value = Configuration.get_config_value(key)
        config_value.should == value
      end
    end

    it 'should not be able to set config value for StudentAttendanceType other than Daily,Subjectwise' do
      config = Configuration.find_by_config_key("StudentAttendanceType")
      config.config_value = "Test"
      config.should be_invalid
    end

    it 'should not be able to set config value for NetworkType than Online,Offline' do
      config = Configuration.find_by_config_key("NetworkState")
      config.config_value = "Test"
      config.should be_invalid
    end


  end

end
