require 'spec_helper'

describe StudentAdditionalDetail do

  it { should belong_to(:student) }
  it { should belong_to(:student_additional_field) }

  describe 'validate presence of additional_info' do
    context 'is_mandatory is true' do
      before { subject.stub(:student_additional_field_is_mandatory?) {true} }
      it { should validate_presence_of(:additional_info) }
    end

    context 'is_mandatory is false' do
      before { subject.stub(:student_additional_field_is_mandatory?) {false} }
      it { should_not validate_presence_of(:additional_info) }
    end
  end

  describe '#destroy_when_additional_info_blank' do
    before do
      @stu_add_field = StudentAdditionalField.new
      @stu_add_detail = StudentAdditionalDetail.new(:student_additional_field => @stu_add_field)
      @stu_add_detail.additional_info = 'sample'
      @stu_add_detail.stub(:student_additional_field_is_mandatory?) {true}
    end

    context 'additional_info and is_mandatory are true' do
      it 'does not destroy StudentAdditionalDetail' do
        @stu_add_detail.valid?
        @stu_add_detail.should_not be_destroyed
      end
    end

    context 'additional_info or is_mandatory is nil' do
      context 'additional_info is nil' do
        before { @stu_add_detail.additional_info = nil }

        it 'destroy StudentAdditionalDetail' do
          @stu_add_detail.valid?
          @stu_add_detail.should be_destroyed
        end
      end

      context 'is_mandatory is false' do
        before { @stu_add_detail.stub(:student_additional_field_is_mandatory?) {false} }

        it 'destroy StudentAdditionalDetail' do
          @stu_add_detail.valid?
          @stu_add_detail.should be_destroyed
        end
      end
    end
  end
end