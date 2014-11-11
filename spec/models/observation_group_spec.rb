require 'spec_helper'

describe ObservationGroup do

  it { should have_many(:observations) }
  it { should have_many(:descriptive_indicators).through(:observations) }
  it { should belong_to(:cce_grade_set) }
  it { should have_and_belong_to_many(:courses) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:header_name) }
  it { should validate_presence_of(:observation_kind) }
  it { should validate_presence_of(:cce_grade_set_id) }
  it { should validate_presence_of(:desc) }

  describe '.active' do
    let!(:observation_group1) { FactoryGirl.create(:observation_group, :is_deleted => false) }
    let!(:observation_group2) { FactoryGirl.create(:observation_group, :is_deleted => true) }

    it 'returns active Observation Group' do
      ObservationGroup.active.should == [observation_group1]
    end
  end
end