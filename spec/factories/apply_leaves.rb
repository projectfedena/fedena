FactoryGirl.define do
  factory :apply_leave do
    reason 'reason'
    start_date Date.today
    end_date Date.today
    employee_leave_type { FactoryGirl.create(:employee_leave_type) }
  end
end
