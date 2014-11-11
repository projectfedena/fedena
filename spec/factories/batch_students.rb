FactoryGirl.define do
  factory :batch_student do
    student { association(:student) }
    batch { association(:batch) }
  end
end
