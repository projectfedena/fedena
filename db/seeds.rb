[
  {"config_key" => "InstitutionName"                 ,"config_value" => "" },
  {"config_key" => "InstitutionAddress"              ,"config_value" => ""},
  {"config_key" => "InstitutionPhoneNo"              ,"config_value" => ""},
  {"config_key" => "StudentAttendanceType"           ,"config_value" => "Daily"},
  {"config_key" => "CurrencyType"                    ,"config_value" => "$"},
  {"config_key" => "Locale"                          ,"config_value" => "en"},
  {"config_key" => "AdmissionNumberAutoIncrement"    ,"config_value" => "1"},
  {"config_key" => "EmployeeNumberAutoIncrement"     ,"config_value" => "1"},
  {"config_key" => "TotalSmsCount"                   ,"config_value" => "0"},
  {"config_key" => "AvailableModules"                ,"config_value" => "HR"},
  {"config_key" => "AvailableModules"                ,"config_value" => "Finance"},
  {"config_key" => "NetworkState"                    ,"config_value" => "Online"},
  {"config_key" => "FinancialYearStartDate"          ,"config_value" => Date.today},
  {"config_key" => "FinancialYearEndDate"            ,"config_value" => Date.today+1.year},
  {"config_key" => "AutomaticLeaveReset"             ,"config_value" => "0"},
  {"config_key" => "LeaveResetPeriod"                ,"config_value" => "4"},
  {"config_key" => "LastAutoLeaveReset"              ,"config_value" => nil}
].each do |param|
  Configuration.find_or_create_by_config_key_and_config_value(param)
end


[
  {"name" => "A"   ,"min_score" => 90 },
  {"name" => "B"   ,"min_score" => 80},
  {"name" => "C"   ,"min_score" => 70},
  {"name" => "D"   ,"min_score" => 60},
  {"name" => "E"   ,"min_score" => 50},
  {"name" => "F"   ,"min_score" => 0}
].each do |param|
  GradingLevel.find_or_create_by_name(param)
end

[
  {"name" => "1"          ,"is_break" => false },
  {"name" => "2"          ,"is_break" => false},
  {"name" => "Interval"   ,"is_break" => true},
  {"name" => "3"          ,"is_break" => false},
  {"name" => "4"          ,"is_break" => false},
  {"name" => "Lunch"      ,"is_break" => true},
  {"name" => "5"          ,"is_break" => false},
  {"name" => "6"          ,"is_break" => false},
  {"name" => "7"          ,"is_break" => false}
].each do |param|
  ClassTiming.find_or_create_by_name(param)
end


EmployeeCategory.find_or_create_by_name(:name => 'Fedena Admin',:prefix => 'Admin',:status => true)

EmployeePosition.find_or_create_by_name(:name => 'Fedena Admin',:employee_category_id => 1,:status => true)

EmployeeDepartment.find_or_create_by_code(:code => 'Admin',:name => 'Fedena Admin',:status => true)

EmployeeGrade.find_or_create_by_name(:name => 'Fedena Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil)

Employee.find_or_create_by_employee_number(:employee_number => 'admin',:joining_date => Date.today,:first_name => 'Fedena',:last_name => 'Administrator',
  :employee_department_id => 1,:employee_grade_id => 1,:employee_position_id => 1,:employee_category_id => 1,:status => true,:nationality_id =>'76', :date_of_birth => Date.today-365)

User.connection.execute "UPDATE users SET admin=1,employee=0 where id = 1"

[
  {"name" => 'Salary'         ,"description" => ' ',"is_income" => false },
  {"name" => 'Donation'       ,"description" => ' ',"is_income" => true},
  {"name" => 'Fee'            ,"description" => ' ',"is_income" => true}
].each do |param|
  FinanceTransactionCategory.find_or_create_by_name(param)
end

[
  {"batch_id" => ""          ,"weekday" => "1" },
  {"batch_id" => ""          ,"weekday" => "2"},
  {"batch_id" => ""          ,"weekday" => "3"},
  {"batch_id" => ""          ,"weekday" => "4"},
  {"batch_id" => ""          ,"weekday" => "5"}
].each do |param|
  Weekday.find_or_create_by_batch_id_and_weekday(param)
end

[
  {"settings_key" => "ApplicationEnabled"                 ,"is_enabled" => false },
  {"settings_key" => "ParentSmsEnabled"                   ,"is_enabled" => false},
  {"settings_key" => "EmployeeSmsEnabled"                 ,"is_enabled" => false},
  {"settings_key" => "StudentSmsEnabled"                  ,"is_enabled" => false},
  {"settings_key" => "ResultPublishEnabled"               ,"is_enabled" => false},
  {"settings_key" => "StudentAdmissionEnabled"            ,"is_enabled" => false},
  {"settings_key" => "ExamScheduleResultEnabled"          ,"is_enabled" => false},
  {"settings_key" => "AttendanceEnabled"                  ,"is_enabled" => false},
  {"settings_key" => "NewsEventsEnabled"                  ,"is_enabled" => false}
].each do |param|
  SmsSetting.find_or_create_by_settings_key(param)
end

