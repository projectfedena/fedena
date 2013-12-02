require 'spec_helper'

describe EmployeeBankDetail do
  it { should belong_to(:employee) }
  it { should belong_to(:bank_field) }

  describe '#archive_employee_bank_detail' do
    let!(:employee_bank_detail) { FactoryGirl.create(:employee_bank_detail) }
    let(:archived_employee) { FactoryGirl.create(:archived_employee) }

    context 'when the attributes are valid' do
      it 'deletes itself' do
        expect {
          employee_bank_detail.archive_employee_bank_detail(archived_employee.id)
        }.to change{ EmployeeBankDetail.count }.by(-1)
        EmployeeBankDetail.find_by_id(employee_bank_detail.id).should be_nil
      end

      it 'creates archived employee bank detail' do
        expect {
          employee_bank_detail.archive_employee_bank_detail(archived_employee.id)
        }.to change{ ArchivedEmployeeBankDetail.count }.by(1)
        ArchivedEmployeeBankDetail.last.employee_id.should == archived_employee.id
      end
    end

    context 'when the attributes are not valid' do
      before do
        ArchivedEmployeeBankDetail.any_instance.stubs(:valid?).returns(false)
      end

      it 'does not delete itself' do
        expect {
          employee_bank_detail.archive_employee_bank_detail(archived_employee.id)
        }.to_not change{ EmployeeBankDetail.count }
        employee_bank_detail.reload.should be_present
      end

      it 'does not create archive employee bank detail' do
        expect {
          employee_bank_detail.archive_employee_bank_detail(archived_employee.id)
        }.to_not change{ ArchivedEmployeeBankDetail.count }
      end
    end
  end
end
