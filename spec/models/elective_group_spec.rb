require 'spec_helper'

describe ElectiveGroup do
  context "validate elective group" do
    before do
      @elective_group1 = Factory.create(:elective_group, :batch_id => 20, :is_deleted => false)
      @elective_group2 = Factory.create(:elective_group, :batch_id => 22, :is_deleted => true)
    end

    it { should belong_to(:batch) }
    it { should have_many(:subjects) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:batch_id) }

    describe '#inactive' do
      it 'must be disabled' do
        @elective_group1.inactivate
        @elective_group1.should be_is_deleted
      end
    end

    describe "scope_name test" do
      describe ".for_batch" do
        it "returns for_batch" do
          ElectiveGroup.for_batch(20).should == [@elective_group1]
        end
      end
    end

  end
end