require 'spec_helper'

describe BatchFeeDiscount do
  it { should belong_to(:receiver).class_name('Batch') }

  it { should validate_presence_of(:receiver_id).with_message(I18n.t('batch_cant_be_blank')) }

  describe '#validate_uniqueness_of name' do
    context 'name is nil' do
      let!(:batch_fee_discount) { FactoryGirl.build(:batch_fee_discount, :name => '') }

      it { should_not validate_uniqueness_of(:name) }
    end

    context 'name is not nil?' do
      let!(:batch_fee_discount) { FactoryGirl.create(:batch_fee_discount) }

      it { should validate_uniqueness_of(:name).scoped_to(:receiver_id, :type) }
    end
  end
end