require 'spec_helper'

describe EmployeeDepartment do
  context 'a new department' do
    before do
      @department1 = Factory.create(:employee_department, :status => true)
      @department2 = Factory.create(:employee_department, :status => false)
    end

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:code) }
    it { should have_many(:employees) }
    it { should have_many(:employee_department_events) }
    it { should have_many(:events).through(:employee_department_events) }

    describe "scope_name test" do
      describe ".active" do
        it "returns active" do
          EmployeeDepartment.active.should == [@department1]
        end
      end
    end

  end
end
