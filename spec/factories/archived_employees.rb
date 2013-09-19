FactoryGirl.define do
  factory :archived_employee do
    sequence(:employee_number)  { |n| "emp#{n}" }
    first_name                  'John'
    last_name                   'Doe'
    joining_date                { Date.current }
    date_of_birth               { Date.current - 20.years }
    sequence(:email)            { |n| "emp#{n}@example.com" }
  end
end
