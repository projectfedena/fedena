FactoryGirl.define do
  factory :employee_user, :class => 'User' do
    sequence(:username) { |n| "emp#{n}" }
    password            { |u1| "#{u1.username}123" }
    email               { |u1| "#{u1.username}@fedena.com" }
    first_name          'John'
    last_name           'Doe'
    role                'Employee'
  end

  factory :admin_user, :class => 'User' do
    sequence(:username) { |n| "admin#{n}" }
    password            { |u1| "#{u1.username}123" }
    email               { |u1| "#{u1.username}@fedena.com" }
    first_name          'John'
    last_name           'Doe'
    role 'Admin'
  end

  factory :reminder do
    recipient { FactoryGirl.create(:employee_user).id }
    body      'Reminding'
  end

  factory :student do
    admission_no    1
    admission_date  Date.today
    date_of_birth   Date.today - 5.years
    first_name      'John'
    middle_name     'K'
    last_name       'Doe'
    address_line1   ''
    address_line2   ''
    batch_id        1
    gender          'm'
    country_id      76
    nationality_id  76
  end

  factory :guardian do
    first_name 'Fname'
    last_name  'Lname'
    relation   'Parent'
  end

  factory :course do
    course_name  '1'
    section_name 'A'
    code         '1A'

    batches { |batches| [batches.association(:batch)] }
  end

  factory :batch do
    name       '2010/11'
    start_date { Date.today }
    end_date   { Date.today + 1.years }
  end

  factory :batch_group do
    name       'batch'
  end

  factory :exam_group do
    sequence(:name) { |n| "Exam Group #{n}" }
    exam_date       { Date.today }
    exam_type       'grades'
    sequence(:cce_exam_category_id) { |n| n }
  end

  factory :grading_level do
    name      'A'
    min_score 85
    order     1
    batch     { Factory.create(:batch) }
  end

  factory :subject do
    name               'Subject'
    code               'SUB'
    max_weekly_classes 8
  end

  factory :exam do
    start_time    { Time.now }
    end_time      { Time.now + 1.hours }
    maximum_marks 100
    minimum_marks 30
    weightage     50
  end

  factory :general_subject, :class => 'Subject' do
    name               'Subject'
    code               'SUB1'
    batch_id           1
    max_weekly_classes 5
    credit_hours       10
  end

  factory :elective_group do
    name     'Test Elective'
    batch_id 1
  end

  factory :employee_department do
    sequence(:name) { |n| "emp_department#{n}" }
    sequence(:code) { |n| "forad#{n}" }
  end

  factory :general_department, :class => 'EmployeeDepartment' do
    name 'Dep1'
    code 'forad'
  end

  factory :employee_category do
    sequence(:name)   { |n| "emp_category#{n}" }
    sequence(:prefix) { |n| "forad#{n}" }
  end

  factory :general_emp_category, :class => 'EmployeeCategory' do
    name   'cat1'
    prefix 'forads'
  end

  factory :weekday do
    weekday     '1'
    day_of_week '1'
    is_deleted  false
    batch_id    nil
  end
end