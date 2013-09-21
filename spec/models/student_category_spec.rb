require 'spec_helper'

describe StudentCategory do

  it { should have_many(:students) }
  #it { should have_many(:fee_category).class_name('FinanceFeeCategory') }
  it { should validate_presence_of(:name) }

  describe '.validate_uniqueness_of_name' do
    context 'is_deleted is false' do
      let!(:student_category) { FactoryGirl.create(:student_category, :is_deleted => false) }

      it { should validate_uniqueness_of(:name).scoped_to(:is_deleted) }
    end

    context 'is_deleted is true' do
      let!(:student_category) { FactoryGirl.create(:student_category, :is_deleted => true) }

      it { should_not validate_uniqueness_of(:name).scoped_to(:is_deleted) }
    end
  end

  describe '#check_dependence' do
    let!(:student_category) { FactoryGirl.create(:student_category, :is_deleted => false) }

    context 'not found student with student_category_id' do
      before { Student.find_all_by_student_category_id(student_category.id) }

      it 'add error to base' do
        student_category.check_dependence
        student_category.errors[:base].should be_true
      end

      it 'returns false' do
        student_category.check_dependence.should be_false
      end
    end
  end

  describe '#empty_students' do
    let!(:student) { FactoryGirl.build(:student) }
    let!(:student_category) { FactoryGirl.create(:student_category) }
    before { Student.stub(:find_all_by_student_category_id).with(student_category.id).and_return([student]) }

    it 'does update all student.student_category_id to nil' do
      student_category.empty_students
      student.student_category_id.should be_nil
    end
  end

  describe '.active' do
    let!(:student_category1) { FactoryGirl.create(:student_category, :is_deleted => false) }
    let!(:student_category2) { FactoryGirl.create(:student_category, :is_deleted => true) }

    it 'returns active student category' do
      active_student_category = StudentCategory.active
      active_student_category.count.should == 1
      active_student_category.should include(student_category1)
    end
  end

end