FactoryGirl.define do
  factory :finance_transaction do
    title 'Title'
    amount 100
    transaction_date 1.day.ago
  end
end
