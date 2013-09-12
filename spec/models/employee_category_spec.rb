require 'spec_helper'

describe EmployeeCategory do
  context 'a new department' do
    before do
      @category1 = Factory.create(:employee_category, :status => true)
      @category2 = Factory.create(:employee_category, :status => false)
    end

    it { should have_many(:employees) }
    it { should have_many(:employee_positions) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:prefix) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:prefix) }

    describe "scope_name test" do
      describe ".active" do
        it "returns active" do
          EmployeeCategory.active.should == [@category1]
        end
      end
    end

  end
end
