require 'spec_helper'

describe FinanceFeeStructureElement do
  it { should belong_to(:batch) }
  it { should belong_to(:student_category) }
  it { should belong_to(:student) }
  it { should belong_to(:parent).class_name('FinanceFeeStructureElement') }
  it { should belong_to(:fee_collection).class_name('FinanceFeeCollection') }
  it { should have_one(:descendant).class_name('FinanceFeeStructureElement') }

  describe '#has_descendant_for_student?' do
    subject { element.has_descendant_for_student?(student) }
    let(:element) { FactoryGirl.create(:finance_fee_structure_element, student_id: student.id) }
    let(:student) { FactoryGirl.create(:student) }
    let(:parent_id) { element.id }
    let(:student_id) { student.id }
    let(:deleted) { false }
    let!(:descendant_element) do
      FactoryGirl.create(:finance_fee_structure_element, parent_id: parent_id,
                                                         student_id: student_id,
                                                         deleted: deleted)
    end

    context 'when parent_id is not match' do
      let(:parent_id) { 0 }
      it { should be_false }
    end

    context 'when student_id is not match' do
      let(:student_id) { 0 }
      it { should be_false }
    end

    context 'when element is deleted' do
      let(:deleted) { true }
      it { should be_false }
    end

    context 'otherwise' do
      it { should be_true }
    end
  end

  describe '.all_fee_components' do
    subject { FinanceFeeStructureElement.all_fee_components }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: nil,
                                                         student_id: nil,
                                                         student_category_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: 1,
                                                         student_id: nil,
                                                         student_category_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.all_fee_components_by_batch' do
    subject { FinanceFeeStructureElement.all_fee_components_by_batch }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: 1,
                                                         student_id: nil,
                                                         student_category_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: nil,
                                                         student_id: nil,
                                                         student_category_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.all_fee_components_by_category' do
    subject { FinanceFeeStructureElement.all_fee_components_by_category }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: nil,
                                                         student_category_id: 1)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: nil,
                                                         student_category_id: nil)
    end

    it { should eql([element_1]) }
  end

  describe '.all_fee_components_by_batch_and_category' do
    subject { FinanceFeeStructureElement.all_fee_components_by_batch_and_category }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: 1,
                                                         student_category_id: 1)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: nil,
                                                         student_category_id: nil)
    end

    it { should eql([element_1]) }
  end

  describe '.fee_components_by_batch_and_category' do
    subject { FinanceFeeStructureElement.fee_components_by_batch_and_category(batch_id, category_id) }
    let(:batch_id) { 1 }
    let(:category_id) { 1 }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id,
                                                         student_category_id: category_id,
                                                         student_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id + 1,
                                                         student_category_id: category_id + 1,
                                                         student_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.student_fee_components_by_batch' do
    subject { FinanceFeeStructureElement.student_fee_components_by_batch(batch_id) }
    let(:batch_id) { 1 }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id,
                                                         student_category_id: nil,
                                                         student_id: nil,
                                                         fee_collection_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id + 1,
                                                         student_category_id: nil,
                                                         student_id: nil,
                                                         fee_collection_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.student_fee_components_by_collection' do
    subject { FinanceFeeStructureElement.student_fee_components_by_collection(date) }
    let(:date) { '12/12/2012' }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, student_category_id: nil,
                                                         student_id: nil,
                                                         fee_collection_id: date,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, student_category_id: nil,
                                                         student_id: nil,
                                                         fee_collection_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.student_fee_components_by_student' do
    subject { FinanceFeeStructureElement.student_fee_components_by_student(student_id) }
    let(:student_id) { 1 }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, student_category_id: nil,
                                                         student_id: student_id,
                                                         parent_id: nil,
                                                         batch_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, student_category_id: nil,
                                                         student_id: nil,
                                                         parent_id: nil,
                                                         batch_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.student_current_fee_cycle' do
    subject { FinanceFeeStructureElement.student_current_fee_cycle(student_id, date) }
    let(:student_id) { 1 }
    let(:date) { '12/12/2012' }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, student_id: student_id,
                                                         parent_id: 1,
                                                         fee_collection_id: date,
                                                         batch_id: nil,
                                                         deleted: false)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, student_id: nil,
                                                         parent_id: nil,
                                                         fee_collection_id: nil,
                                                         batch_id: nil,
                                                         deleted: false)
    end

    it { should eql([element_1]) }
  end

  describe '.batch_fee_component_by_batch' do
    subject { FinanceFeeStructureElement.batch_fee_component_by_batch(batch_id) }
    let(:batch_id) { 1 }
    let!(:element_1) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id,
                                                         student_category_id: 1)
    end
    let!(:element_2) do
      FactoryGirl.create(:finance_fee_structure_element, batch_id: batch_id + 1,
                                                         student_category_id: 1)
    end

    it { should eql([element_1]) }
  end

  describe '.get_all_fee_components' do
    let(:all) { 'all' }
    let(:by_batch) { 'by_batch' }
    let(:by_category) { 'by_category' }
    let(:by_batch_and_category) { 'by_batch_and_category' }

    it 'should get all fee components' do
      FinanceFeeStructureElement.expects(:all_fee_components).returns(all)
      FinanceFeeStructureElement.expects(:all_fee_components_by_batch).returns(by_batch)
      FinanceFeeStructureElement.expects(:all_fee_components_by_category).returns(by_category)
      FinanceFeeStructureElement.expects(:all_fee_components_by_batch_and_category)
                                .returns(by_batch_and_category)
      elements = FinanceFeeStructureElement.get_all_fee_components
      elements[:all].should == all
      elements[:by_category].should == by_category
      elements[:by_batch].should == by_batch
      elements[:by_batch_and_category].should == by_batch_and_category
    end
  end

  describe '.get_student_fee_components' do
    let(:student) do
      FactoryGirl.create(:student, batch_id: batch_id,
                                   student_category_id: student_category_id)
    end
    let(:batch_id) { 1 }
    let(:student_category_id) { 1 }
    let(:date) { 'date' }
    let(:all) { 'all' }
    let(:by_batch) { 'by_batch' }
    let(:by_category) { 'by_category' }
    let(:by_batch_and_category) { 'by_batch_and_category' }
    let(:by_batch_and_fee_collection) { 'by_batch_and_fee_collection' }
    let(:student_element) { 'student' }
    let(:student_current_fee_cycle) { 'student_current_fee_cycle' }

    it 'should get all student fee components' do
      FinanceFeeStructureElement.expects(:all_fee_components).returns(all)
      FinanceFeeStructureElement.expects(:student_fee_components_by_batch)
                                .with(batch_id).returns(by_batch)
      FinanceFeeStructureElement.expects(:student_fee_components_by_collection)
                                .with(date).returns(by_batch_and_fee_collection)
      FinanceFeeStructureElement.expects(:fee_components_by_batch_and_category)
                                .with(nil, student_category_id).returns(by_category)
      FinanceFeeStructureElement.expects(:fee_components_by_batch_and_category)
                                .with(batch_id, student_category_id).returns(by_batch_and_category)
      FinanceFeeStructureElement.expects(:student_fee_components_by_student)
                                .with(student.id).returns(student_element)
      FinanceFeeStructureElement.expects(:student_current_fee_cycle)
                                .with(student.id, date).returns(student_current_fee_cycle)
      elements = FinanceFeeStructureElement.get_student_fee_components(student, date)
      elements[:all].should == all
      elements[:by_category].should == by_category
      elements[:by_batch].should == by_batch
      elements[:by_batch_and_category].should == by_batch_and_category
      elements[:by_batch_and_fee_collection].should == by_batch_and_fee_collection
      elements[:student].should == student_element
      elements[:student_current_fee_cycle].should == student_current_fee_cycle
    end
  end

  describe '.get_batch_fee_components' do
    let(:batch) { FactoryGirl.create(:batch) }
    let(:all) { 'all' }
    let(:by_batch) { 'by_batch' }
    let(:by_category) { 'by_category' }
    let(:by_batch_and_category) { 'by_batch_and_category' }

    it 'should get all batch fee components' do
      FinanceFeeStructureElement.expects(:all_fee_components).returns(all)
      FinanceFeeStructureElement.expects(:fee_components_by_batch_and_category)
                                .with(batch.id, nil).returns(by_batch)
      FinanceFeeStructureElement.expects(:all_fee_components_by_category).returns(by_category)
      FinanceFeeStructureElement.expects(:batch_fee_component_by_batch)
                                .with(batch.id).returns(by_batch_and_category)
      elements = FinanceFeeStructureElement.get_batch_fee_components(batch)
      elements[:all].should == all
      elements[:by_category].should == by_category
      elements[:by_batch].should == by_batch
      elements[:by_batch_and_category].should == by_batch_and_category
    end
  end
end
