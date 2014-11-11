require 'spec_helper'

describe EmployeesSubject do
  it { should belong_to(:employee) }
  it { should belong_to(:subject) }
  it { should have_one(:batch).through(:subject) }

  describe '.employee_overloaded?' do
    before do
      @employee = FactoryGirl.create(:employee)
      Employee.stub(:find).with(@employee.id).and_return(@employee)
      @subject1 = FactoryGirl.create(:subject, :max_weekly_classes => 2)
      @subject2 = FactoryGirl.create(:subject, :max_weekly_classes => 2)
    end

    context 'assign hours exceeds max hours per week' do
      before { @employee.stub(:max_hours_per_week).and_return(1) }

      it 'returns true' do
        EmployeesSubject.employee_overloaded?(@employee.id, [@subject1.id, @subject2.id]).should be_true
      end
    end

    context 'assign hours is less than max hours per week' do
      before { @employee.stub(:max_hours_per_week).and_return(5) }

      it 'returns false' do
        EmployeesSubject.employee_overloaded?(@employee.id, [@subject1.id, @subject2.id]).should be_false
      end
    end
  end

  describe '.allot_work' do
    before do
      @employee = FactoryGirl.create(:employee)
      @subject1 = FactoryGirl.create(:subject)
      @subject2 = FactoryGirl.create(:subject)
      @hash = [
        [@subject1.id, @employee.id],
        [@subject2.id, @employee.id],
      ]
    end

    context 'employee is overloaded' do
      before { EmployeesSubject.stub(:employee_overloaded?).with(@employee.id, [@subject1.id, @subject2.id]).and_return(true) }

      it 'does not create employees_subject' do
        lambda { EmployeesSubject.allot_work(@hash) }.should change { EmployeesSubject.count }.by(0)
      end

      it 'returns false' do
        EmployeesSubject.allot_work(@hash).should be_false
      end
    end

    context 'employee is not overloaded' do
      before { EmployeesSubject.stub(:employee_overloaded?).with(@employee.id, [@subject1.id, @subject2.id]).and_return(false) }

      it 'creates 2 employees_subject' do
        lambda { EmployeesSubject.allot_work(@hash) }.should change { EmployeesSubject.count }.by(2)
      end

      it 'returns true' do
        EmployeesSubject.allot_work(@hash).should be_true
      end
    end

    context 'failed to save employees_subject record' do
      before do
        EmployeesSubject.stub(:employee_overloaded?).with(@employee.id, [@subject1.id, @subject2.id]).and_return(false)
        EmployeesSubject.any_instance.expects(:save).returns(false)
      end

      it 'does not create employees_subject' do
        lambda { EmployeesSubject.allot_work(@hash) }.should change { EmployeesSubject.count }.by(0)
      end

      it 'returns false' do
        EmployeesSubject.allot_work(@hash).should be_false
      end
    end
  end
end