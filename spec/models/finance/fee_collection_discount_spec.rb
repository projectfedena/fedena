require 'spec_helper'

describe FeeCollectionDiscount do
  describe '#category_name' do
    context 'student category is found' do
      let(:student_category) { FactoryGirl.create(:student_category, :name => 'Baby') }
      let(:fee_collection_discount) { FactoryGirl.create(:fee_collection_discount, :receiver_id => student_category.id) }

      it 'returns student category name' do
        fee_collection_discount.category_name.should == 'Baby'
      end
    end

    context 'student category is not found' do
      let(:fee_collection_discount) { FactoryGirl.create(:fee_collection_discount, :receiver_id => 88888) }

      it 'returns nil' do
        fee_collection_discount.category_name.should be_nil
      end
    end
  end

  describe '#student_name' do
    context 'student is found' do
      let(:student) { FactoryGirl.create(:student, :first_name => 'Steve', :admission_no => '123') }
      let(:fee_collection_discount) { FactoryGirl.create(:fee_collection_discount, :receiver_id => student.id) }

      it 'returns student student first name and admission no' do
        fee_collection_discount.student_name.should == 'Steve (123)'
      end
    end

    context 'student is not found' do
      let(:fee_collection_discount) { FactoryGirl.create(:fee_collection_discount, :receiver_id => 88888) }

      it 'returns nil' do
        fee_collection_discount.student_name.should be_nil
      end
    end
  end
end
