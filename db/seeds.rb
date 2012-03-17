Configuration.create :config_key => "InstitutionName", :config_value => ""
Configuration.create :config_key => "InstitutionAddress", :config_value => ""
Configuration.create :config_key => "InstitutionPhoneNo", :config_value => ""
Configuration.create :config_key => "StudentAttendanceType", :config_value => "Daily"
Configuration.create :config_key => "CurrencyType", :config_value => "$"
Configuration.create :config_key => "Locale", :config_value=>"en"
Configuration.create :config_key => "AdmissionNumberAutoIncrement", :config_value => "1"
Configuration.create :config_key => "EmployeeNumberAutoIncrement", :config_value => "1"
Configuration.create :config_key => "TotalSmsCount", :config_value=>"0"
Configuration.create :config_key => "AvailableModules", :config_value=>"HR"
Configuration.create :config_key => "AvailableModules", :config_value=>"Finance"

GradingLevel.create(:name   => 'A',:min_score => '90')
GradingLevel.create(:name   => 'B',:min_score => '80')
GradingLevel.create(:name   => 'C',:min_score => '70')
GradingLevel.create(:name   => 'D',:min_score => '60')
GradingLevel.create(:name   => 'E',:min_score => '50')
GradingLevel.create(:name   => 'F',:min_score => '0')


ClassTiming.create(:name => "1",        :is_break => false)
ClassTiming.create(:name => "2",        :is_break => false)
ClassTiming.create(:name => "Interval", :is_break => true)
ClassTiming.create(:name => "3",        :is_break => false)
ClassTiming.create(:name => "4",        :is_break => false)
ClassTiming.create(:name => "Lunch",    :is_break => true)
ClassTiming.create(:name => "5",        :is_break => false)
ClassTiming.create(:name => "6",        :is_break => false)
ClassTiming.create(:name => "7",        :is_break => false)

EmployeeCategory.create :name => 'Fedena Admin',:prefix => 'Admin',:status => true

EmployeePosition.create :name => 'Fedena Admin',:employee_category_id => 1,:status => true

EmployeeDepartment.create :code => 'Admin',:name => 'Fedena Admin',:status => true

EmployeeGrade.create :name => 'Fedena Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil

Employee.create :employee_number => 'admin',:joining_date => Date.today,:first_name => 'Fedena',:last_name => 'Administrator',
:employee_department_id => 1,:employee_grade_id => 1,:employee_position_id => 1,:employee_category_id => 1,:status => true,:nationality_id =>'76', :date_of_birth => Date.today-365
User.connection.execute "UPDATE users SET admin=1,employee=0 where id = 1"

FinanceTransactionCategory.create(:name => 'Salary', :description => ' ', :is_income => false)
FinanceTransactionCategory.create(:name => 'Donation', :description => ' ', :is_income => true)
FinanceTransactionCategory.create(:name => 'Fee', :description => ' ', :is_income => true)

Weekday.create :batch_id=>"", :weekday=>"1"
Weekday.create :batch_id=>"", :weekday=>"2"
Weekday.create :batch_id=>"", :weekday=>"3"
Weekday.create :batch_id=>"", :weekday=>"4"
Weekday.create :batch_id=>"", :weekday=>"5"

SmsSetting.create :settings_key=>"ApplicationEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"ParentSmsEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"EmployeeSmsEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"StudentSmsEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"ResultPublishEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"StudentAdmissionEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"ExamScheduleResultEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"AttendanceEnabled",:is_enabled=>false
SmsSetting.create :settings_key=>"NewsEventsEnabled",:is_enabled=>false

Configuration.create :config_key => "NetworkState", :config_value=>"Online"
Configuration.create :config_key => "FinancialYearStartDate", :config_value=>Date.today
Configuration.create :config_key => "FinancialYearEndDate", :config_value=>Date.today+1.year
Configuration.create :config_key => "AutomaticLeaveReset", :config_value => "0"
Configuration.create :config_key => "LeaveResetPeriod", :config_value => "4"
Configuration.create :config_key => "LastAutoLeaveReset", :config_value => nil

