FactoryGirl.define do
  factory :finance_transaction do
    title 'Title'
    amount 100
    transaction_date 1.day.ago
    category { Factory.create(:finance_transaction_category) }
  end
end
