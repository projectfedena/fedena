require 'spec_helper'

describe EmployeeLeave do
  it { should belong_to(:employee_leave_type) }

  describe '.reset_all' do
    let(:employee_number) { 2 }
    let!(:employee_leaves) { create_list(:employee_leave, employee_number) }

    it 'calls reset for all employee leave' do
      EmployeeLeave.any_instance.expects(:reset).times(employee_number)
      EmployeeLeave.reset_all
    end
  end

  describe '#reset' do
    let(:employee_leave_type) { create(:employee_leave_type, status: status) }
    let(:employee_leave) do
      create(:employee_leave,
             employee_leave_type_id: employee_leave_type.id)
    end

    context 'when leave type is active' do
      let(:status) { true }
      it 'calculates leave days' do
        employee_leave.expects(:calculate_leave_days)
        employee_leave.reset
      end
    end

    context 'when leave type is inactive' do
      let(:status) { false }
      it 'does not calculates leave days' do
        employee_leave.expects(:calculate_leave_days).never
        employee_leave.reset
      end
    end
  end

  describe '#calculate_leave_days' do
    let(:max_leave_count) { 50 }
    let(:leave_taken) { 10 }
    let(:leave_count) { 20 }
    let(:carry_forward) { true}
    let(:employee_leave_type) do
      create(:employee_leave_type,
             carry_forward: carry_forward,
             max_leave_count: max_leave_count)
    end
    let(:employee_leave) do
      create(:employee_leave,
             employee_leave_type_id: employee_leave_type.id,
             leave_taken: leave_taken,
             leave_count: leave_count)
    end

    before { employee_leave.calculate_leave_days }

    context 'always' do
      it 'updates leave taken and reset date' do
        employee_leave.reload.reset_date.should == Date.today
        employee_leave.leave_taken.should == 0
      end
    end

    context 'when leave days can not be carried forward' do
      let(:leave_taken) { 20 }
      let(:leave_count) { 10 }

      it 'updates leave count by default leave count' do
        employee_leave.reload.leave_count.should == max_leave_count
      end
    end

    context 'when leave days can not be carried forward' do
      let(:carry_forward) { false }

      it 'updates leave count by default leave count' do
        employee_leave.reload.leave_count.should == max_leave_count
      end
    end

    context 'otherwise' do
      it 'updates leave count' do
        employee_leave.reload.leave_count.should == leave_count - leave_taken + max_leave_count
      end
    end
  end

  describe '#update_leave_taken_by' do
    let(:leave_taken) { 10 }
    subject { create(:employee_leave, leave_taken: leave_taken) }
    before { subject.update_leave_taken_by(is_half_day) }

    context 'when is half day is true' do
      let(:is_half_day) { true }

      it 'increases half day' do
        subject.reload.leave_taken.should == leave_taken + 0.5
      end
    end

    context 'when is half day is false' do
      let(:is_half_day) { false }

      it 'increases full day' do
        subject.reload.leave_taken.should == leave_taken + 1
      end
    end
  end
end
