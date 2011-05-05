
StudentCategory.destroy_all
StudentCategory.create([
  {:name=>"OBC",:is_deleted=>false},
  {:name=>"General",:is_deleted=>false}
  ])

#HR modules defaults

#EmployeeCategory.delete_all
EmployeeCategory.create([
#  {:name => 'Fedena Admin',:prefix => 'Admin',:status => true},
  {:name => 'Management',:prefix => 'MGMT',:status => true},
  {:name => 'Teaching',:prefix => 'TCR',:status => true},
  {:name => 'Non-Teaching',:prefix => 'NTCR',:status => true}
  ])

#EmployeePosition.delete_all
EmployeePosition.create([
#  {:name => 'Fedena Admin',:employee_category_id => 1,:status => true},
  {:name => 'Principal',:employee_category_id => 2,:status => true},
  {:name => 'HR',:employee_category_id => 2,:status => true},
  {:name => 'Sr.Teacher',:employee_category_id => 3,:status => true},
  {:name => 'Jr.Teacher',:employee_category_id => 3,:status => true},
  {:name => 'Clerk',:employee_category_id => 4,:status => true}
  ])

#EmployeeDepartment.delete_all
EmployeeDepartment.create([
#  {:code => 'Admin',:name => 'Fedena Admin',:status => true},
  {:code => 'MGMT',:name => 'Management',:status => true},
  {:code => 'MAT',:name => 'Mathematics',:status => true},
  {:code => 'OFC',:name => 'Office',:status => true},
  ])

#EmployeeGrade.delete_all
EmployeeGrade.create([
#  {:name => 'Fedena Admin',:priority => 0 ,:status => true,:max_hours_day=>nil,:max_hours_week=>nil},
  {:name => 'A',:priority => 1 ,:status => true,:max_hours_day=>1,:max_hours_week=>5},
  {:name => 'B',:priority => 2 ,:status => true,:max_hours_day=>3,:max_hours_week=>15},
  {:name => 'C',:priority => 3 ,:status => true,:max_hours_day=>4,:max_hours_week=>20},
  {:name => 'D',:priority => 4 ,:status => true,:max_hours_day=>5,:max_hours_week=>25},
  ])

PayrollCategory.delete_all
PayrollCategory.create([
  {:name=>"Basic",:percentage=>nil,:payroll_category_id=>nil,:is_deduction=>false,:status=>true},
  {:name=>"Medical Allowance",:percentage=>3,:payroll_category_id=>1,:is_deduction=>false,:status=>true},
  {:name=>"Travel Allowance",:percentage=>5,:payroll_category_id=>1,:is_deduction=>false,:status=>true},
  {:name=>"Mobile deduction",:percentage=>nil,:payroll_category_id=>nil,:is_deduction=>true,:status=>true},
  {:name=>"PF",:percentage=>5,:payroll_category_id=>1,:is_deduction=>true,:status=>true},
  {:name=>"State tax",:percentage=>3,:payroll_category_id=>5,:is_deduction=>true,:status=>true}
  ])

BankField.delete_all
BankField.create([
  {:name=>"Bank Name",:status=>true},
  {:name=>"Bank Branch",:status=>true},
  {:name=>"Account No",:status=>true},
  ])

AdditionalField.delete_all
AdditionalField.create([
  {:name=>"Liscence Number",:status=>true},
  {:name=>"PAN",:status=>true},
  {:name=>"LIC",:status=>true},
  ])

#Employee.delete_all
Employee.create([
#  {:employee_number => 'admin',:joining_date => Date.today,:first_name => 'Admin',:last_name => 'Employee',
#   :employee_department_id => 1,:employee_grade_id => 1,:employee_position_id => 1,
#   :employee_category_id => 1,:date_of_birth => Date.today-365},
  {:employee_number => 'EMP1',:joining_date => Date.today,:first_name => 'Unni',:last_name => 'Koroth',
   :employee_department_id => 2,:employee_grade_id => 2,:employee_position_id => 2,
   :employee_category_id => 2,:date_of_birth => Date.today-365},
  {:employee_number => 'EMP2',:joining_date => Date.today,:first_name => 'Vishwajith',:last_name => 'A',
   :employee_department_id => 2,:employee_grade_id => 1,:employee_position_id => 3,
   :employee_category_id => 2,:date_of_birth => Date.today-365},
  {:employee_number => 'EMP3',:joining_date => Date.today,:first_name => 'Aravind',:last_name => 'GS',
   :employee_department_id => 3,:employee_grade_id => 3,:employee_position_id => 4,
   :employee_category_id => 3,:date_of_birth => Date.today-365},
  {:employee_number => 'EMP4',:joining_date => Date.today,:first_name => 'Nithin',:last_name => 'Bekal',
   :employee_department_id => 3,:employee_grade_id => 4,:employee_position_id => 5,
   :employee_category_id => 3,:date_of_birth => Date.today-365},
  {:employee_number => 'EMP5',:joining_date => Date.today,:first_name => 'Ralu',:last_name => 'RM',
   :employee_department_id => 4,:employee_grade_id => 5,:employee_position_id => 6,
   :employee_category_id => 4,:date_of_birth => Date.today-365}
  ])

#user creations
#User.delete_all
User.create([
#   {:username   => 'admin',:password   => 'admin123',:first_name => 'Fedena',
#    :last_name  => 'Administrator',:email=> 'admin@fedena.com',:role=> 'Admin'},
   {:username   => 'EMP1',:password   => 'EMP1123',:first_name => 'Unni',
    :last_name  => 'Koroth',:email=> 'unni@fedena.com',:role=> 'Employee'},
   {:username   => 'EMP2',:password   => 'EMP2123',:first_name => 'Vishwajith',
    :last_name  => 'A',:email=> 'vishu@fedena.com',:role=> 'Employee'},
   {:username   => 'EMP3',:password   => 'EMP3123',:first_name => 'Aravind',
    :last_name  => 'GS',:email=> 'aravind@fedena.com',:role=> 'Employee'},
   {:username   => 'EMP4',:password   => 'EMP4123',:first_name => 'Nithin',
    :last_name  => 'Bekal',:email=> 'nithin@fedena.com',:role=> 'Employee'},
   {:username   => 'EMP5',:password   => 'EMP5123',:first_name => 'Ralu',
    :last_name  => 'RM',:email=> 'ralu@fedena.com',:role=> 'Employee'},
   {:username   => '1',:password   => '1123',:first_name => 'John',
    :last_name  => 'Doe',:email=> 'john@fedena.com',:role=> 'Student'},
   {:username   => '2',:password   => '2123',:first_name => 'Samantha',
    :last_name  => 'Fowler',:email=> 'samantha@fedena.com',:role=> 'Student'}
  ])

SmsSetting.delete_all
SmsSetting.create([
  {:settings_key=>"ApplicationEnabled",:is_enabled=>false},
  {:settings_key=>"ParentSmsEnabled",:is_enabled=>false},
  {:settings_key=>"StudentSmsEnabled",:is_enabled=>false},
  {:settings_key=>"StudentAdmissionEnabled",:is_enabled=>false},
  {:settings_key=>"ExamScheduleResultEnabled",:is_enabled=>false},
  {:settings_key=>"ResultPublishEnabled",:is_enabled=>false},
  {:settings_key=>"AttendanceEnabled",:is_enabled=>false},
  {:settings_key=>"NewsEventsEnabled",:is_enabled=>false},
  {:settings_key=>"EmployeeSmsEnabled",:is_enabled=>false}
  ])
