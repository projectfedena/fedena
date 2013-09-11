require 'spec_helper'

describe ElectiveGroup do

  it { should belong_to(:batch) }
  it { should have_many(:subjects) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:batch_id) }

  describe '#inactive' do
    let(:elective_group) { Factory.create(:elective_group) }

    it 'must be disabled' do
      elective_group.inactivate
      elective_group.should be_is_deleted
    end
  end

  describe '.for_batch' do
    before do
      @elective_group1 = Factory.create(:elective_group, :batch_id => 20, :is_deleted => false)
      @elective_group2 = Factory.create(:elective_group, :batch_id => 22, :is_deleted => true)
    end

    it 'returns for_batch' do
      ElectiveGroup.for_batch(20).should == [@elective_group1]
    end
  end
end