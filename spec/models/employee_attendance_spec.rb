require 'spec_helper'

describe EmployeeAttendance do

  it { should belong_to(:employee) }
  it { should belong_to(:employee_leave_type) }
  it { should validate_presence_of(:employee_leave_type_id) }
  it { should validate_presence_of(:reason) }

  context 'a exists record' do
    let!(:employ_atten) { Factory.create(:employee_attendance) }

    it { should validate_uniqueness_of(:employee_id).scoped_to(:attendance_date) }

    describe '#date_marked_is_earlier_than_joining_date' do
      before do
        employ_atten.attendance_date = Date.current - 10.days
        employ_atten.employee.joining_date = Date.current
      end

      it 'returns invalid when attendance_date < employee.joining_date' do
        employ_atten.should be_invalid
      end

    end
  end

end