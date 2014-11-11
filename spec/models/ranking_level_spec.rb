require 'spec_helper'

describe RankingLevel do
  before do
    @course        = FactoryGirl.create(:course, :grading_type => '1')
    @ranking_level = FactoryGirl.create(:ranking_level, :course => @course)
    Configuration.create(:config_key => 'CCE', :config_value => '1')
    Configuration.create(:config_key => 'GPA', :config_value => '1')
    Configuration.create(:config_key => 'CWA', :config_value => '1')
  end

  it { should belong_to(:course) }

  it { should validate_presence_of(:name) }
  it { should validate_numericality_of(:subject_count) }

  it do
    pending 'TO FIX'
    should validate_numericality_of(:gpa).with_message('is not a number')
  end

  it do
    pending 'TO FIX'
    should validate_numericality_of(:marks).with_message('is not a number')
  end
end
