FactoryGirl.define do
  factory :employee_position do
    sequence(:name) { |n| "name #{n}" }
    employee_category_id 1 # hard code employee_category_id to prevent creating category in employee_attendant_controller_spec:282
  end
end
