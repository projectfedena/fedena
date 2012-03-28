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

[
  {"name" => "English"    ,"code" => 'en' },
  {"name" => "Spanish"    ,"code" => 'es'},
].each do |param|
  Language.find_or_create_by_settings_key(param)
end

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
  "Zimbabwe"].each do |c|
  Country.find_or_create_by_name(c)
end



["ExaminationControl",
  "EnterResults",
  "ViewResults",
  "Admission",
  "StudentsControl",
  "ManageNews",
  "ManageTimetable",
  "StudentAttendanceView",
  "HrBasics",
  "AddNewBatch",
  "SubjectMaster",
  "EventManagement",
  "GeneralSettings",
  "FinanceControl",
  "TimetableView",
  "StudentAttendanceRegister",
  "EmployeeAttendance",
  "PayslipPowers",
  "EmployeeSearch",
  "SMSManagement"].each do |p|
  Privilege.find_or_create_by_name(p)
end

