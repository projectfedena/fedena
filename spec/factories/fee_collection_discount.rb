FactoryGirl.define do
  factory :batch_fee_collection_discount do
    sequence(:name) { |n| "Batch fee collection discount #{n}" }
    discount        20
    type            'BatchFeeCollectionDiscount'
    is_amount       false
    receiver_id     1
  end

  factory :student_fee_collection_discount do
    sequence(:name) { |n| "student fee collection discount #{n}" }
    discount        20
    type            'StudentFeeCollectionDiscount'
    is_amount       false
    receiver_id     1
  end

  factory :student_category_fee_collection_discount do
    sequence(:name) { |n| "student category fee collection discount #{n}" }
    discount        20
    type            'StudentCategoryFeeCollectionDiscount'
    is_amount       false
    receiver_id     1
  end
end
