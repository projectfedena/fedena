require 'spec_helper'

describe EmployeeAdditionalDetail do
  it { should belong_to(:employee) }
  it { should belong_to(:additional_field) }

  describe '.validate_presence_of additional_info' do
    subject { FactoryGirl.create(:employee_additional_detail,
      :additional_field => FactoryGirl.create(:additional_field, :is_mandatory => true)) }

    it { should validate_presence_of(:additional_info) }
  end

  describe '#archive_employee_additional_detail' do
    let(:employee_add_detail) { FactoryGirl.create(:employee_additional_detail, 
      :additional_field => FactoryGirl.create(:additional_field)) }
    let(:archived_employee) { FactoryGirl.create(:archived_employee) }

    it 'archived employee additional detail' do
      lambda { employee_add_detail.archive_employee_additional_detail(archived_employee) }.should change { ArchivedEmployeeAdditionalDetail.count }.by(1) 
    end
  end

  describe '#destroy_if_additional_info_is_blank' do
    context 'additional_info is nil' do
      let(:employee_add_detail) { FactoryGirl.build(:employee_additional_detail, 
        :additional_field => FactoryGirl.create(:additional_field, :is_mandatory => false),
        :additional_info => nil) }

      it 'returns destroyed' do
        employee_add_detail.valid?
        employee_add_detail.should be_destroyed
      end
    end
  end
end