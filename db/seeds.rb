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
  {"config_key" => "NetworkState"                    ,"config_value" => "Online"},
  {"config_key" => "FinancialYearStartDate"          ,"config_value" => Date.today},
  {"config_key" => "FinancialYearEndDate"            ,"config_value" => Date.today+1.year},
  {"config_key" => "AutomaticLeaveReset"             ,"config_value" => "0"},
  {"config_key" => "LeaveResetPeriod"                ,"config_value" => "4"},
  {"config_key" => "LastAutoLeaveReset"              ,"config_value" => nil},
  {"config_key" => "GPA"                             ,"config_value" => "0"},
  {"config_key" => "CWA"                             ,"config_value" => "0"},
  {"config_key" => "CCE"                             ,"config_value" => "0"},
  {"config_key" => "DefaultCountry"                  ,"config_value" => "76"},
  {"config_key" => "FirstTimeLoginEnable"            ,"config_value" => "0"}
].each do |param|
  Configuration.find_or_create_by_config_key(param)
end

[
  {"config_key" => "AvailableModules"                ,"config_value" => "HR"},
  {"config_key" => "AvailableModules"                ,"config_value" => "Finance"}
].each do |param|
  Configuration.find_or_create_by_config_key_and_config_value(param)
end

if GradingLevel.count == 0
  [
    {"name" => "A"   ,"min_score" => 90 },
    {"name" => "B"   ,"min_score" => 80},
    {"name" => "C"   ,"min_score" => 70},
    {"name" => "D"   ,"min_score" => 60},
    {"name" => "E"   ,"min_score" => 50},
    {"name" => "F"   ,"min_score" => 0}
  ].each do |param|
    GradingLevel.create(param)
  end
end


if User.first( :conditions=>{:admin=>true}).blank?

  employee_category = EmployeeCategory.find_or_create_by_prefix(:name => 'System Admin',:prefix => 'Admin',:status => true)

  employee_position = EmployeePosition.find_or_create_by_name(:name => 'System Admin',:employee_category_id => employee_category.id,:status => true)

  employee_department = EmployeeDepartment.find_or_create_by_code(:code => 'Admin',:name => 'System Admin',:status => true)

  employee_grade = EmployeeGrade.find_or_create_by_name(:name => 'System Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil)

  employee = Employee.find_or_create_by_employee_number(:employee_number => 'admin',:joining_date => Date.today,:first_name => 'Admin',:last_name => 'User',
    :employee_department_id => employee_department.id,:employee_grade_id => employee_grade.id,:employee_position_id => employee_position.id,:employee_category_id => employee_category.id,:status => true,:nationality_id =>'76', :date_of_birth => Date.today-365, :email => 'noreply@fedena.com')

  employee.user.update_attributes(:admin=>true,:employee=>false)

end

[
  {"name" => 'Salary'         ,"description" => ' ',"is_income" => false },
  {"name" => 'Donation'       ,"description" => ' ',"is_income" => true},
  {"name" => 'Fee'            ,"description" => ' ',"is_income" => true}
].each do |param|
  FinanceTransactionCategory.find_or_create_by_name(param)
end

if Weekday.count == 0
  [
    {"batch_id" => nil          ,"weekday" => "1"     ,"day_of_week" => "1"   ,"is_deleted"=> false },
    {"batch_id" => nil          ,"weekday" => "2"     ,"day_of_week" => "2"   ,"is_deleted"=> false },
    {"batch_id" => nil          ,"weekday" => "3"     ,"day_of_week" => "3"   ,"is_deleted"=> false },
    {"batch_id" => nil          ,"weekday" => "4"     ,"day_of_week" => "4"   ,"is_deleted"=> false },
    {"batch_id" => nil          ,"weekday" => "5"     ,"day_of_week" => "5"   ,"is_deleted"=> false }
  ].each do |param|
    Weekday.create(param)
  end
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


Privilege.all.each do |p|
  p.update_attributes(:description=> p.name.underscore+"_privilege")
end

Event.all.each do |e|
  e.destroy if e.origin_type=="AdditionalExam"
end
 
#insert record in privilege_tags table
[
  {"name_tag" => "system_settings", "priority"=>5},
  {"name_tag" => "administration_operations", "priority"=>1},
  {"name_tag" => "academics", "priority"=>3},
  {"name_tag" => "student_management", "priority"=>2},
  {"name_tag" => "social_other_activity", "priority"=>4},
].each do |param|
  PrivilegeTag.find_or_create_by_name_tag(param)
end

#add priorities to student additional fields with nil priority, if any
addl_fields = StudentAdditionalField.all
unless addl_fields.empty?
  priority=1
  last_priority = addl_fields.collect(&:priority).compact.sort.last
  unless last_priority.nil?
    priority = last_priority + 1
  end
  nil_priority_fields = addl_fields.reject{|f| !(f.priority.nil?)}
  nil_priority_fields.each do|p|
    p.update_attributes(:priority=>priority)
    priority+=1
  end
end

#add priorities to employee additional fields with nil priority, if any
addl_fields = AdditionalField.all
unless addl_fields.empty?
  priority=1
  last_priority = addl_fields.collect(&:priority).compact.sort.last
  unless last_priority.nil?
    priority = last_priority + 1
  end
  nil_priority_fields = addl_fields.reject{|f| !(f.priority.nil?)}
  nil_priority_fields.each do|p|
    p.update_attributes(:priority=>priority)
    priority+=1
  end
end


#add privilege_tag_id, priority in privileges table
#system_settings
Privilege.reset_column_information
system_settings_tag = PrivilegeTag.find_by_name_tag('system_settings')
Privilege.find_by_name('GeneralSettings').update_attributes(:privilege_tag_id=>system_settings_tag.id, :priority=>10 )
Privilege.find_by_name('AddNewBatch').update_attributes(:privilege_tag_id=>system_settings_tag.id, :priority=>20 )
Privilege.find_by_name('SubjectMaster').update_attributes(:privilege_tag_id=>system_settings_tag.id, :priority=>30 )
Privilege.find_by_name('SMSManagement').update_attributes(:privilege_tag_id=>system_settings_tag.id, :priority=>40 )


#administration_operations
administration_operations_tag = PrivilegeTag.find_by_name_tag('administration_operations')
Privilege.find_by_name('HrBasics').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>50 )
Privilege.find_by_name('EmployeeSearch').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>60 )
Privilege.find_by_name('EmployeeAttendance').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>70 )
Privilege.find_by_name('PayslipPowers').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>80 )
Privilege.find_by_name('FinanceControl').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>90 )
Privilege.find_by_name('EventManagement').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>100 )
Privilege.find_by_name('ManageNews').update_attributes(:privilege_tag_id=>administration_operations_tag.id, :priority=>110 )
#academics
academics_tag = PrivilegeTag.find_by_name_tag('academics')
Privilege.find_by_name('ExaminationControl').update_attributes(:privilege_tag_id=>academics_tag.id, :priority=>230 )
Privilege.find_by_name('EnterResults').update_attributes(:privilege_tag_id=>academics_tag.id, :priority=>240 )
Privilege.find_by_name('ViewResults').update_attributes(:privilege_tag_id=>academics_tag.id, :priority=>250 )
Privilege.find_by_name('ManageTimetable').update_attributes(:privilege_tag_id=>academics_tag.id, :priority=>260 )
Privilege.find_by_name('TimetableView').update_attributes(:privilege_tag_id=>academics_tag.id, :priority=>270 )
#student_management
student_management_tag = PrivilegeTag.find_by_name_tag('student_management')
Privilege.find_by_name('Admission').update_attributes(:privilege_tag_id=>student_management_tag.id, :priority=>280 )
Privilege.find_by_name('StudentsControl').update_attributes(:privilege_tag_id=>student_management_tag.id, :priority=>290 )
Privilege.find_by_name('StudentView').update_attributes(:privilege_tag_id=>student_management_tag.id, :priority=>300 )
Privilege.find_by_name('StudentAttendanceRegister').update_attributes(:privilege_tag_id=>student_management_tag.id, :priority=>310 )
Privilege.find_by_name('StudentAttendanceView').update_attributes(:privilege_tag_id=>student_management_tag.id, :priority=>320 )

#update gender as string
Employee.all.each do |e|
  if e.gender.to_s=="1"
    e.update_attributes(:gender=> "m")
  elsif e.gender.to_s=="0"
    e.update_attributes(:gender=> "f")
  end
end

ArchivedEmployee.all.each do |e|
  if e.gender.to_s=="1"
    e.update_attributes(:gender=> "m")
  elsif e.gender.to_s=="0"
    e.update_attributes(:gender=> "f")
  end
end

#add country
[ "Afghanistan",
  "Albania",
  "Algeria",
  "Andorra",
  "Angola",
  "Antigua & Deps",
  "Argentina",
  "Armenia",
  "Australia",
  "Austria",
  "Azerbaijan",
  "Bahamas",
  "Bahrain",
  "Bangladesh",
  "Barbados",
  "Belarus",
  "Belgium",
  "Belize",
  "Benin",
  "Bhutan",
  "Bolivia",
  "Bosnia Herzegovina",
  "Botswana",
  "Brazil",
  "Brunei",
  "Bulgaria",
  "Burkina",
  "Burundi",
  "Cambodia",
  "Cameroon",
  "Canada",
  "Cape Verde",
  "Central African Rep",
  "Chad",
  "Chile",
  "China",
  "Colombia",
  "Comoros",
  "Congo",
  "Congo {Democratic Rep}",
  "Costa Rica",
  "Croatia",
  "Cuba",
  "Cyprus",
  "Czech Republic",
  "Denmark",
  "Djibouti",
  "Dominica",
  "Dominican Republic",
  "East Timor",
  "Ecuador",
  "Egypt",
  "El Salvador",
  "Equatorial Guinea",
  "Eritrea",
  "Estonia",
  "Ethiopia",
  "Fiji",
  "Finland",
  "France",
  "Gabon",
  "Gambia",
  "Georgia",
  "Germany",
  "Ghana",
  "Greece",
  "Grenada",
  "Guatemala",
  "Guinea",
  "Guinea-Bissau",
  "Guyana",
  "Haiti",
  "Honduras",
  "Hungary",
  "Iceland",
  "India",
  "Indonesia",
  "Iran",
  "Iraq",
  "Ireland {Republic}",
  "Israel",
  "Italy",
  "Ivory Coast",
  "Jamaica",
  "Japan",
  "Jordan",
  "Kazakhstan",
  "Kenya",
  "Kiribati",
  "Korea North",
  "Korea South",
  "Kosovo",
  "Kuwait",
  "Kyrgyzstan",
  "Laos",
  "Latvia",
  "Lebanon",
  "Lesotho",
  "Liberia",
  "Libya",
  "Liechtenstein",
  "Lithuania",
  "Luxembourg",
  "Macedonia",
  "Madagascar",
  "Malawi",
  "Malaysia",
  "Maldives",
  "Mali",
  "Malta",
  "Montenegro",
  "Marshall Islands",
  "Mauritania",
  "Mauritius",
  "Mexico",
  "Micronesia",
  "Moldova",
  "Monaco",
  "Mongolia",
  "Morocco",
  "Mozambique",
  "Myanmar, {Burma}",
  "Namibia",
  "Nauru",
  "Nepal",
  "Netherlands",
  "New Zealand",
  "Nicaragua",
  "Niger",
  "Nigeria",
  "Norway",
  "Oman",
  "Pakistan",
  "Palau",
  "Panama",
  "Papua New Guinea",
  "Paraguay",
  "Peru",
  "Philippines",
  "Poland",
  "Portugal",
  "Qatar",
  "Romania",
  "Russian Federation",
  "Rwanda",
  "St Kitts & Nevis",
  "St Lucia",
  "Saint Vincent & the Grenadines",
  "Samoa",
  "San Marino",
  "Sao Tome & Principe",
  "Saudi Arabia",
  "Senegal",
  "Serbia",
  "Seychelles",
  "Sierra Leone",
  "Singapore",
  "Slovakia",
  "Slovenia",
  "Solomon Islands",
  "Somalia",
  "South Africa",
  "Spain",
  "Sri Lanka",
  "Sudan",
  "Suriname",
  "Swaziland",
  "Sweden",
  "Switzerland",
  "Syria",
  "Taiwan",
  "Tajikistan",
  "Tanzania",
  "Thailand",
  "Togo",
  "Tonga",
  "Trinidad & Tobago",
  "Tunisia",
  "Turkey",
  "Turkmenistan",
  "Tuvalu",
  "Uganda",
  "Ukraine",
  "United Arab Emirates",
  "United Kingdom",
  "United States",
  "Uruguay",
  "Uzbekistan",
  "Vanuatu",
  "Vatican City",
  "Venezuea",
  "Vietnam",
  "Yemen",
  "Zambia",
  "Zimbabwe",
  "Palestine"].each do |param|
  Country.find_or_create_by_name(param)
end

