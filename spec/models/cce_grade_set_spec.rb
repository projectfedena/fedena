require 'spec_helper'

describe CceGradeSet do

  it { should have_many(:observation_groups) }
  it { should have_many(:cce_grades) }
  it { should validate_presence_of(:name) }

  describe '#grade_string_for' do
    let(:cce_grade) { CceGrade.new(:name => 'Cce Grade Name', :grade_point => 10) }
    let(:cce_grade_set) { CceGradeSet.new }

    context 'found cce_grade with grade_point' do
      before { cce_grade_set.stub(:cce_grades).and_return([cce_grade]) }

      it 'returns name of cce_grade' do
        cce_grade_set.grade_string_for(10).should == 'Cce Grade Name'
      end
    end

    context 'not found cce_grade with grade_point' do
      before { cce_grade_set.stub(:cce_grades).and_return([]) }

      it 'returns No Grade' do
        cce_grade_set.grade_string_for(10).should == 'No Grade'
      end
    end
  end

  describe '#max_grade_point' do
    let(:cce_grade1) { CceGrade.new(:grade_point => 10) }
    let(:cce_grade2) { CceGrade.new(:grade_point => 15) }
    let(:cce_grade_set) { CceGradeSet.new }

    context 'has cce_grade.grade_point' do
      before { cce_grade_set.stub(:cce_grades).and_return([cce_grade1, cce_grade2]) }

      it 'returns max grade_point' do
        cce_grade_set.max_grade_point.should == 15
      end
    end

    context 'empty cce_grade' do
      before { cce_grade_set.stub(:cce_grades).and_return([]) }

      it 'returns 1' do
        cce_grade_set.max_grade_point.should == 1
      end
    end
  end

end