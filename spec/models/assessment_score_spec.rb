require 'spec_helper'

describe AssessmentScore do
  it { should belong_to(:student) }
  it { should belong_to(:descriptive_indicator) }
  it { should belong_to(:exam) }

  describe '.co_scholastic' do
    let!(:assessment_score1) { AssessmentScore.create(:exam_id => nil) }
    let!(:assessment_score2) { AssessmentScore.create(:exam_id => 5) }

    it 'returns co_scholastic with exam_id is nil' do
      AssessmentScore.co_scholastic.should == [assessment_score1]
    end
  end

  describe '.scholastic' do
    let!(:assessment_score1) { AssessmentScore.create(:exam_id => 0) }
    let!(:assessment_score2) { AssessmentScore.create(:exam_id => 5) }

    it 'returns scholastic with exam_id > 0' do
      AssessmentScore.scholastic.should == [assessment_score2]
    end
  end
end
