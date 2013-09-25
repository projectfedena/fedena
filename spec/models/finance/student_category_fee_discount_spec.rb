require 'spec_helper'

describe StudentCategoryFeeDiscount do
  it { should belong_to(:receiver).class_name('StudentCategory') }
  it { should validate_presence_of(:receiver_id).with_message(I18n.t('student_category_cant_be_blank')) }

  describe '#validate_uniqueness_of name' do
    context 'name is nil' do
      let!(:student_category_fee_discount) { FactoryGirl.build(:student_category_fee_discount, :name => '') }

      it { should_not validate_uniqueness_of(:name) }
    end

    context 'name is not nil?' do
      let!(:student_category_fee_discount) { FactoryGirl.create(:student_category_fee_discount,
        :receiver => FactoryGirl.create(:student_category)) }

      it { should validate_uniqueness_of(:name).scoped_to(:finance_fee_category_id, :type) }
    end
  end
end