require 'spec_helper'

describe ApplyLeave do
  it { should validate_presence_of(:employee_leave_type_id) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:reason) }

  it { should belong_to(:employee) }
  it { should belong_to(:employee_leave_type) }

  describe '#approve' do
    let(:manager_remark) { 'manager_remark' }
    subject { create(:apply_leave) }
    before { subject.approve(manager_remark) }

    its(:approved) { should be_true }
    its(:viewed_by_manager) { should be_true }
    its(:manager_remark) { should eql(manager_remark) }
  end

  describe '#create_employee_attendance' do
    let(:day) { Date.parse('10/10/2010') }
    let(:apply_leave) { create(:apply_leave) }
    subject { apply_leave.create_employee_attendance(day) }

    it { should be_valid }
    its(:attendance_date) { should eql(day) }
    its(:employee_id) { should eql(apply_leave.id) }
    its(:employee_leave_type_id) { should eql(apply_leave.employee_leave_type_id) }
    its(:reason) { should eql(apply_leave.reason) }
    its(:is_half_day) { should eql(apply_leave.is_half_day) }
  end

  describe '#calculate_reset_count' do
    let(:manager_remark) { 'manager_remark' }
    let(:params) { { manager_remark: manager_remark } }
    let(:employee) { create(:employee, joining_date: 10.days.ago) }
    let(:leave_type) { create(:employee_leave_type) }
    let(:apply_leave) {
      create(:apply_leave,
             employee_id: employee.id,
             employee_leave_type_id: leave_type.id,
             start_date: 7.days.ago.to_date,
             end_date: 1.day.from_now.to_date)
    }

    before do
      apply_leave.expects(:approve).with(manager_remark).returns(approved)
    end

    context 'when apply leave is not approved' do
      let(:approved) { false }

      it 'does not do anything' do
        apply_leave.expects(:create_employee_attendance).never
        apply_leave.calculate_reset_count(params)
      end
    end

    context 'when apply leave is approved' do
      let(:approved) { true }
      let!(:employee_leave) do
        create(:employee_leave,
               employee_id: employee.id,
               employee_leave_type_id: leave_type.id)
      end

      it 'creates employee attendace' do
        EmployeeLeave.any_instance.expects(:update_leave_taken_by).with(apply_leave.is_half_day).at_least_once
        apply_leave.expects(:create_employee_attendance).at_least_once
        apply_leave.calculate_reset_count(params)
      end
    end
  end
end
