require 'spec_helper'

describe EmployeeGrade do
  it { should validate_presence_of(:name) }

  it { should validate_numericality_of(:priority) }

  it { should have_many(:employee) }

  context 'a exists record' do
    let!(:employee_grade) { FactoryGirl.create(:employee_grade) }

    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:priority) }

    describe '#max_hours_week_should_be_greater_than_max_hours_day' do
      context 'when max_hours_day > max_hours_week' do
        before do
          employee_grade.max_hours_day = 20
          employee_grade.max_hours_week = 15
        end

        it 'is invalid' do
          employee_grade.should be_invalid
        end
      end
    end
  end

  describe '.active' do
    let!(:employee_grade1) { FactoryGirl.create(:employee_grade, :status => true) }
    let!(:employee_grade2) { FactoryGirl.create(:employee_grade, :status => false) }

    it 'returns active employee grade' do
      active_employ_grade = EmployeeGrade.active
      active_employ_grade.count.should == 1
      active_employ_grade.should include(employee_grade1)
    end
  end
end