require 'spec_helper'

describe ArchivedEmployee do
  it { should belong_to(:employee_category) }
  it { should belong_to(:employee_position) }
  it { should belong_to(:employee_grade) }
  it { should belong_to(:employee_department) }
  it { should belong_to(:nationality).class_name('Country') }

  it { should have_many(:archived_employee_bank_details)}
  it { should have_many(:archived_employee_additional_details) }

  describe '.set_status_false' do
    let!(:archived_employee) { FactoryGirl.build(:archived_employee) }

    it 'returns archived_employee status' do
      archived_employee.save
      archived_employee.status.should be_false
    end
  end

  describe '#full_name' do
    let(:archived_employee) { FactoryGirl.build(:archived_employee,
      :first_name  => 'A1',
      :middle_name => 'B2',
      :last_name   => 'C3') }

    it 'returns full_name' do
      archived_employee.full_name.should == 'A1 B2 C3'
    end
  end
end