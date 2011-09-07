
Factory.define :employee_user, :class => User do |u|
  u.sequence(:username) { |n| "emp#{n}" }
  u.password            { |u1| "#{u1.username}123" }
  u.email               { |u1| "#{u1.username}@fedena.com" }
  u.first_name          'John'
  u.last_name           'Doe'
  u.role                'Employee'
end

Factory.define :admin_user, :class => User do |u|
  u.sequence(:username) { |n| "admin#{n}" }
  u.password { |u1| "#{u1.username}123" }
  u.first_name 'Fedena'
  u.sequence(:last_name) { |n| "Admin#{n}"}
  u.email { |u1| "#{u1.username}@fedena.com" }
  u.role 'Admin'
end

Factory.define :student do |s|
  s.admission_no    1
  s.admission_date  Date.today
  s.date_of_birth   Date.today - 5.years
  s.first_name      'John'
  s.middle_name     'K'
  s.last_name       'Doe'
  s.address_line1   ''
  s.address_line2   ''
  s.batch_id        1
  s.gender          'm'
  s.country_id      76
  s.nationality_id  76
end

Factory.define :guardian do |g|
  g.first_name 'Fname'
  g.last_name  'Lname'
  g.relation   'Parent'
end

Factory.define :course do |c|
  c.course_name  '1'
  c.section_name 'A'
  c.code         '1A'

  c.batches { |batches| [batches.association(:batch)] }
end

Factory.define :batch do |b|
  b.name       '2010/11'
  b.start_date Date.today
  b.end_date   Date.today + 1.years
end

Factory.define :exam_group do |e|
  e.sequence(:name) { |n| "Exam Group #{n}" }
  e.exam_date       Date.today
end

Factory.define :subject do |s|
  s.name               'Subject'
  s.code               'SUB'
  s.max_weekly_classes 8
end

Factory.define :exam do |e|
  e.start_time    Time.now
  e.end_time      Time.now + 1.hours
  e.maximum_marks 100
  e.minimum_marks 30
  e.weightage     50
end

Factory.define :general_subject,:class=>"Subject" do |s|
  s.name  "Subject"
  s.code   "SUB1"
  s.batch_id           1
  s.max_weekly_classes 5
end

Factory.define :elective_group do |s|
  s.name  "Test Elective"
  s.batch_id           1
end



















































































































Factory.define :employee_department do |e|
  e.sequence(:name) { |n| "emp_department#{n}" }
  e.sequence(:code) { |n| "forad#{n}" }
end

Factory.define :general_department,:class=>"EmployeeDepartment" do |s|
  s.name  "Dep1"
  s.code   "forad"
end

Factory.define :employee_category do |e|
  e.sequence(:name) { |n| "emp_category#{n}" }
  e.sequence(:prefix) { |n| "forad#{n}" }
end

Factory.define :general_emp_category,:class=>"EmployeeCategory" do |s|
  s.name  "cat1"
  s.prefix   "forads"
end
