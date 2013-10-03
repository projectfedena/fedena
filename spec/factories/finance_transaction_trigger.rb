FactoryGirl.define do
  factory :finance_transaction_trigger do
    finance_category_id 1
    percentage 60
    title 'FTT title'
    description 'FTT description'
  end
end
