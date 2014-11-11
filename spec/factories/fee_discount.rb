FactoryGirl.define do
  factory :student_category_fee_discount do
    sequence(:name) { |n| "name #{n}" }
    type "StudentCategoryFeeDiscount"
    finance_fee_category_id 1
    discount 20
    receiver  { FactoryGirl.create(:student_category) }
  end

  factory :student_fee_discount do
    name      'student fee discount 1'
    discount  20
    type      'StudentFeeDiscount'
    receiver  { FactoryGirl.create(:student) }
  end

  factory :batch_fee_discount do
    sequence(:name) { |n| "Batch fee discount #{n}" }
    discount        30
    type            'BatchFeeDiscount'
    receiver_id     1
  end
end
