FactoryGirl.define do
  factory :finance_transaction_category do
    sequence(:name) { |number| "category ##{number}" }
  end
end
