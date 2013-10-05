FactoryGirl.define do
  factory :exam_score do
    marks       20
    student { FactoryGirl.create(:student) }
    exam { FactoryGirl.create(:exam) }
  end
end
