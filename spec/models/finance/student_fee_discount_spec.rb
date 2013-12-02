require 'spec_helper'

describe StudentFeeDiscount do
  it { should belong_to(:receiver).class_name('Student') }

  it { should validate_presence_of(:receiver_id).with_message(I18n.t('student_admission_no_cant_be_blank')) }
  #it { should validate_uniqueness_of(:name).with_message(I18n.t('student_admission_no_cant_be_blank')) }

  describe '#validate_uniqueness_of name' do
    context 'name is nil' do
      let!(:student_fee_discount) { FactoryGirl.build(:student_fee_discount, :name => '') }

      it { should_not validate_uniqueness_of(:name) }
    end

    context 'name is not nil?' do
      let!(:student_fee_discount) { FactoryGirl.create(:student_fee_discount) }

      it { should validate_uniqueness_of(:name).scoped_to(:finance_fee_category_id, :type, :receiver_id) }
    end
  end
end